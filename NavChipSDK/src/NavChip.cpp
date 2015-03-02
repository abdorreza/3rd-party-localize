/******************************************************************************
** InterSense NavChip Developer Kit
**
** The InterSense NavChip Developer Kit sample code is considered proprietary
** and confidential. The NavChip Developer Kit sample code is available for
** use by customers who have signed the InterSense NDA and otherwise shall not
** be distributed without the written consent of InterSense Incorporated.
**
** Filename: NavChip.c
** Modified: 14 Dec 2009
**
** Comments: This module contains public and private functions for basic
**           NavChip interactions. Note that the communication link with the
**           NavChip is assumed to be very reliable. No additional code to
**           recover from communication dropouts (such as retries) is
**           included.
**
**           See also NavChip.h for public function descriptions.
**
**           The sample source code in this project is provided for use by
**           InterSense customers with the limitations and restrictions as
**           defined above. It is supplied without any warranty or implied
**           suitability or fitness for any particular purpose.
******************************************************************************/

#include <stdio.h>
#include <string.h>

#include <NavChipSDK/NavChip.h>

/* Address range used to search for devices in ncOpen(). Range can be
 reduced to speed up detection if it is known that the device is not
 using an address outside the range. Valid range is 0-7 */
#define NC_MIN_ADDRESS 0
#define NC_MAX_ADDRESS 7

/* Baud rates used to search for NavChips in ncOpen(). This list can be
shortened to speed up detection if it is known which rates are in use.
 Likewise, additional rates can be added if necessary. The rates most
 likely to be in use should come first to minimize search time */
static int _rate[] = {115200, 38400, 230400, 460800, 921600};

/* Port number range used to search for NavChips in ncOpen(). Range can
 reduced to speed up detection if it is known that the device is not on
 port outside the range. Valid range is 0-OS_MAX_PORT_NUMBER */
#define NC_MIN_PORT_NUMBER 0
#define NC_MAX_PORT_NUMBER OS_MAX_PORT_NUMBER

/* First byte of any command */
#define NC_START_BYTE 0xA5

/* Command nibbles */
#define NC_CMD_PING 0x0
#define NC_CMD_GET_REGISTER 0x1
#define NC_CMD_SET_REGISTER 0x2
#define NC_CMD_START_STREAM 0x5

/* Buffer sizes for command and response buffers */
#define NC_MAX_CMD_LEN 32
#define NC_MAX_RSP_LEN 200

/* Max time from power up to standby mode (ms). If a ping command is sent,
 the NavChip makes an early transition into standby mode and this delay
 can be reduced to 100 ms */
#define NC_DELAY_INIT 600

/* Max time to receive response (ms). The NavChip responds to commands
 within 5 ms, but the timeout used for waiting for responses should
 be higher and depends on worst-case latency of the communication
 link and OS */
#define NC_TIMEOUT_RESPONSE 40

/* Connected to NavChip? */
static BOOL _connected = FALSE;

/* NavChip streaming data? */
static BOOL _streaming = FALSE;

/* Serial port number */
static int _portNumber = 0;

/* NavChip address */
static int _ncAddress = 0;

/* Response buffer */
static UINT8 _response[NC_MAX_RSP_LEN];

/* Data packet type for streaming */
static UINT8 _packetType = 0;

/* Data packet buffer */
static UINT8 _packet[NC_MAX_RSP_LEN];

/* Data packet buffer position (index of next empty location) */
static int _packetPos = 0;

/* Data packet is ready to retrieve? */
static BOOL _packetReady = FALSE;

/* Time most recent data packet was read */
static UINT32 _packetTime = 0;

/* Total length of packets in bytes */
static int _packetLen[] = {15, /* packet type 1 */
                           17, /* packet type 2 */
                           19, /* packet type 3 */
                           21, /* packet type 4 */
                           13, /* packet type 5 */
                           15, /* packet type 6 */
                           25, /* packet type 7 */
                           27, /* packet type 8 */
                           29, /* packet type 9 */
};

/******************************************************************************
** _calcChecksum - Calculate arithmetic checksum for given buffer
**
** Inputs:
**   buf - input buffer
**   len - number of bytes in buffer
**
** Outputs:
**   none
**
** Returns:
**   checksum
******************************************************************************/
static UINT8 _calcChecksum(UINT8 buf[], int len) {
    int i;
    char sum = 0;

    for (i = 0; i < len; i++) {
        sum += buf[i];
    }
    return (UINT8)(-sum);
}

/******************************************************************************
** _buildCommand - Adds start byte, address and checksum into command buffer
**
** Inputs:
**   addr - NavChip address
**   cmd  - command buffer
**   len  - length of command including checksum
**
** Outputs:
**   cmd  - command buffer
**
** Returns:
**   none
******************************************************************************/
static void _buildCommand(int addr, UINT8 cmd[], int len) {
    /* Set start byte */
    cmd[0] = NC_START_BYTE;

    /* Set address nibble */
    cmd[1] &= 0xF;
    cmd[1] |= addr << 4;

    /* Set checksum */
    cmd[len - 1] = _calcChecksum(cmd, len - 1);
}

/******************************************************************************
** _issueCommand - Sends command to NavChip and waits for response if one
**                 is expected
**
** Inputs:
**   cmd    - command buffer
**   cmdLen - number of bytes in command
**   rspLen - response length in bytes (0 if none)
**
** Outputs:
**   rsp - response buffer
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
static BOOL _issueCommand(UINT8 cmd[], int cmdLen, int rspLen, UINT8 rsp[]) {
    int rcvCount;
    int totRcvCount;
    UINT32 t0;

    /* Flush receive buffer of anything leftover from earlier then
     send command */
    if (!osComPortFlush(_portNumber) || !osComPortWrite(_portNumber, cmd, cmdLen)) {
        return FALSE;
    }

    /* If response is expected... */
    if (rspLen > 0) {
        totRcvCount = 0;
        t0 = osTimeGet();

        /* Read bytes until expected number are received or timeout expires */
        do {
            if (!osComPortRead(_portNumber, rsp + totRcvCount, rspLen - totRcvCount, &rcvCount)) {
                return FALSE;
            }
            totRcvCount += rcvCount;

            /* Expected number of bytes received? */
            if (totRcvCount >= rspLen) {
                break;
            }

            /* Sleep to avoid excessive CPU load */
            osTimeWait(1);
        } while (osTimeGetElapsed(t0) < NC_TIMEOUT_RESPONSE);

        /* Check number of bytes received */
        if (totRcvCount == 0) {
#ifdef _VERBOSE
            osErrorDisplay("No response received");
#endif
            return FALSE;
        } else if (totRcvCount != rspLen) {
            osErrorDisplay("Incorrect response length");
            return FALSE;
        }

        /* Validate echo */
        if (rsp[0] != cmd[1]) {
#ifdef _VERBOSE
            osErrorDisplay("Invalid echo");
#endif
            return FALSE;
        }

        /* Validate checksum for multibyte responses */
        if (rspLen > 1 && _calcChecksum(rsp, rspLen) != 0) {
            osErrorDisplay("Invalid checksum");
            return FALSE;
        }
    }

    return TRUE;
}

/******************************************************************************
** _issuePing - Sends ping command to NavChip and waits for response if one
**              is expected
**
** Inputs:
**   wait - wait for response?
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
static BOOL _issuePing(BOOL wait) {
    UINT8 cmd[NC_MAX_CMD_LEN];
    int cmdLen;
    int rspLen = 0;

    /* Form ping command */
    cmdLen = 1; /* start byte */
    cmd[cmdLen++] = NC_CMD_PING;
    cmdLen++; /* add one for checksum */
    _buildCommand(_ncAddress, cmd, cmdLen);

    /* Wait for response if expected */
    if (wait) {
        rspLen = 1;
    }

    return _issueCommand(cmd, cmdLen, rspLen, _response);
}

/*****************************************************************************/

BOOL ncOpen(int *port, int *address, int *rate) {
    int rateIdx;
    UINT8 type;

    _streaming = FALSE;

    /* Close in case already open */
    ncClose();

    /* Wait for device to start in case it was just powered up. If searching
     a number of ports and addresses, it is faster to wait once up front.
     Otherwise, a ping command can be sent to cause an early transition
     into standby mode to save time */
    osTimeWait(NC_DELAY_INIT);

    /* Try available ports */
    for (_portNumber = NC_MIN_PORT_NUMBER; _portNumber <= NC_MAX_PORT_NUMBER; _portNumber++) {
        if (osComPortOpen(_portNumber)) {
            /* Try different baud rates */
            for (rateIdx = 0; rateIdx < static_cast<int>(NELEM(_rate)); rateIdx++) {
                *rate = _rate[rateIdx];

                if (osComPortSetRate(_portNumber, *rate)) {
                    /* Try each possible NavChip address */
                    for (_ncAddress = NC_MIN_ADDRESS; _ncAddress <= NC_MAX_ADDRESS; _ncAddress++) {
                        /* Send ping and if a response comes back... */
                        if (_issuePing(TRUE)) {
                            _connected = TRUE;

                            /* Check if device is a NavChip */
                            if (ncGetRegister(NC_REG_DEVICE_TYPE, 1, &type)) {
                                if (type == NC_DEVICE_TYPE) {
                                    /* Found a NavChip */
                                    *port = _portNumber;
                                    *address = _ncAddress;
                                    return TRUE;
                                }
                                osErrorDisplay("Non-NavChip device detected (ignored)");
                            }
                            _connected = FALSE;
                        }
                    }
                }
            }
            osComPortClose(_portNumber);
        }
    }

    _connected = FALSE;
    return FALSE;
}

/*****************************************************************************/

BOOL ncClose(void) {
    if (_connected) {
        osComPortClose(_portNumber);
        _connected = FALSE;
        _streaming = FALSE;
    }
    return TRUE;
}

/*****************************************************************************/

BOOL ncGetRegister(UINT8 regAddress, int count, UINT8 value[]) {
    UINT8 cmd[NC_MAX_CMD_LEN];
    int cmdLen;
    int i;

    if (!_connected || _streaming) {
        osErrorDisplay("Operation not allowed");
        return FALSE;
    }

    if (count < 0 || count > 4) {
        osErrorDisplay("Count out of range");
        return FALSE;
    }

    /* Get register values */
    for (i = 0; i < count; i++) {
        /* Form get register command */
        cmdLen = 1; /* start byte */
        cmd[cmdLen++] = NC_CMD_GET_REGISTER;
        cmd[cmdLen++] = regAddress + i;
        cmdLen++; /* add one for checksum */
        _buildCommand(_ncAddress, cmd, cmdLen);

        /* Send command and wait for 3-byte response containing register value */
        if (!_issueCommand(cmd, cmdLen, 3, _response)) {
            return FALSE;
        }

        /* Extract register value from response */
        value[i] = _response[1];
    }
    return TRUE;
}

/*****************************************************************************/

BOOL ncSetRegister1(UINT8 regAddress, UINT8 value) { return ncSetRegisterM(regAddress, 1, &value); }

BOOL ncSetRegisterM(UINT8 regAddress, int count, const UINT8 value[]) {
    UINT8 cmd[NC_MAX_CMD_LEN];
    int cmdLen;
    int i;

    if (!_connected || _streaming) {
        osErrorDisplay("Operation not allowed");
        return FALSE;
    }

    if (count < 1 || count > 4) {
        osErrorDisplay("Count out of range");
        return FALSE;
    }

    /* Set register values */
    for (i = 0; i < count; i++) {
        /* Form set register command */
        cmdLen = 1; /* start byte */
        cmd[cmdLen++] = NC_CMD_SET_REGISTER;
        cmd[cmdLen++] = regAddress + i;
        cmd[cmdLen++] = value[i];
        cmdLen++; /* add one for checksum */
        _buildCommand(_ncAddress, cmd, cmdLen);

        /* Send command and wait for 1-byte ack */
        if (!_issueCommand(cmd, cmdLen, 1, _response)) {
            return FALSE;
        }
    }
    return TRUE;
}

/*****************************************************************************/

BOOL ncStartStreaming(void) {
    UINT8 cmd[NC_MAX_CMD_LEN];
    int cmdLen;

    if (!_connected || _streaming) {
        osErrorDisplay("Operation not allowed");
        return FALSE;
    }

    /* Get packet type for streaming */
    if (!ncGetRegister(NC_REG_PACKET_TYPE, 1, &_packetType)) {
        osErrorDisplay("Failed to get packet type");
        return FALSE;
    }

    /* Allow only supported packet types */
    if (_packetType > NELEM(_packetLen)) {
        osErrorDisplay("Unsupported packet type");
        return FALSE;
    }

    /* Form start streaming command */
    cmdLen = 1; /* start byte */
    cmd[cmdLen++] = NC_CMD_START_STREAM;
    cmdLen++; /* add one for checksum */
    _buildCommand(_ncAddress, cmd, cmdLen);

    /* Send command (NavChip sends no response) */
    if (!_issueCommand(cmd, cmdLen, 0, NULL)) {
        return FALSE;
    }
    _streaming = TRUE;
    _packetPos = 0;
    _packetReady = FALSE;
    _packetTime = osTimeGet();

    return TRUE;
}

/*****************************************************************************/

BOOL ncReadPacket(BOOL *ready) {
    int rcvCount;
    int reqCount;
    int packetLen;
    UINT8 header;

    _packetReady = *ready = FALSE;

    if (!_connected || !_streaming) {
        osErrorDisplay("Not streaming");
        return FALSE;
    }

    /* This implementation uses the knowledge of the expected packet type.
     It is also possible to parse the packet type from the stream without
     knowing it in advance */

    /* Determine number of bytes in packet (less any bytes already in buffer) */
    packetLen = _packetLen[_packetType - 1];
    reqCount = packetLen - _packetPos;

    /* Read bytes */
    osComPortRead(_portNumber, _packet + _packetPos, reqCount, &rcvCount);

    /* Advance packet position index by number of bytes received */
    _packetPos += rcvCount;

    /* Not enough bytes for a full packet? */
    if (_packetPos < packetLen) {
        /* If timeout has expired, then reset timeout period and indicate error */
        if (osTimeGetElapsed(_packetTime) > NC_TIMEOUT_RESPONSE) {
            _packetTime = osTimeGet();
            return FALSE;
        }

        /* Otherwise, just return so caller can try reading again */
        return TRUE;
    }

    /* Validate header byte, packet type and checksum */
    header = (_ncAddress << 4) | NC_CMD_START_STREAM;

    if (_packet[0] != header || _packet[1] != _packetType ||
        _calcChecksum(_packet, packetLen) != 0) {
        int i;

        /* Packet is invalid. Scan for another header byte */
        for (i = 1; i < packetLen; i++) {
            _packetPos--;

            /* Toss bytes before candidate header byte */
            if (_packet[i] == header) {
                memmove(_packet, _packet + i, _packetPos);
                break;
            }
        }

        /* Toss all bytes if no header is found */
        if (_packet[0] != header) {
            _packetPos = 0;
        }

#ifdef _VERBOSE
        osErrorDisplay("Invalid packet");
#endif
        return FALSE;
    }

    /* Packet received. Reset buffer and set ready flags */
    _packetTime = osTimeGet();
    _packetPos = 0;
    _packetReady = *ready = TRUE;
    return TRUE;
}

/*****************************************************************************/

BOOL ncGetData(ncPacketDataType *data) {
    int i, j;

    if (!_connected || !_streaming || !_packetReady) {
        osErrorDisplay("Packet not available");
        return FALSE;
    }

    /* Packet type is in the same location in all packet formats */
    data->packetType = _packet[1];

    /* These items are in these locations for all packets except 1 and 2 */
    if (_packetType > 2) {
        data->packetId = _packet[2];
        data->flags = _packet[3];
        data->timestamp = ncLittleEndian16(_packet + 4);
    }

    /* Parse packet according to type (supports packet types 1-9) */
    switch (_packetType) {
        case 1:
        case 2:
            data->packetId = ((_packet[3] << 0) & 0xF0) | ((_packet[5] >> 4) & 0x0F);
            data->flags = ((_packet[3] << 4) & 0xC0) | ((_packet[5] << 2) & 0x30) |
                          ((_packet[7] << 0) & 0x0C);
            data->timestamp = ((_packet[7] << 8) & 0xF000) | ((_packet[9] << 4) & 0x0F00) |
                              ((_packet[11] << 0) & 0x00F0) | ((_packet[13] >> 4) & 0x000F);

            for (i = 0; i < 3; i++) {
                data->deltaV[i] = ncLittleEndian16(_packet + 2 + i * 2);
                data->deltaV[i] <<= 6; /* shift left and right to extend sign bit */
                data->deltaV[i] >>= 6;

                data->deltaTheta[i] = ncLittleEndian16(_packet + 8 + i * 2);
                data->deltaTheta[i] <<= 4; /* shift left and right to extend sign bit */
                data->deltaTheta[i] >>= 4;
            }

            if (_packetType == 2) {
                data->mag = ncLittleEndian16(_packet + 14);
                data->mag <<= 2; /* shift left and right to extend sign bit */
                data->mag >>= 2;

                /* Insert I field into flag byte */
                data->flags |= (_packet[15] >> 6) & 0x03;
            }
            break;

        /* These types all have deltaTheta and deltaV in common */
        case 3:
        case 4:
        case 8:
        case 9:
            for (i = 0; i < 3; i++) {
                data->deltaV[i] = ncLittleEndian16(_packet + 6 + i * 2);
                data->deltaTheta[i] = ncLittleEndian16(_packet + 12 + i * 2);
            }

            /* These types all have mag data in common except type 3 */
            if (_packetType != 3) {
                data->mag = ncLittleEndian16(_packet + 18);
            }

            if (_packetType == 8) {
                for (i = 0; i < 3; i++) {
                    data->euler[i] = ncLittleEndian16(_packet + 20 + i * 2);
                }
            } else if (_packetType == 9) {
                for (i = 0; i < 4; i++) {
                    data->quat[i] = ncLittleEndian16(_packet + 20 + i * 2);
                }
            }
            break;

        case 5:
            for (i = 0; i < 3; i++) {
                data->euler[i] = ncLittleEndian16(_packet + 6 + i * 2);
            }
            break;

        case 6:
            for (i = 0; i < 4; i++) {
                data->quat[i] = ncLittleEndian16(_packet + 6 + i * 2);
            }
            break;

        case 7:
            for (i = 0; i < 3; i++) {
                for (j = 0; j < 3; j++) {
                    data->rot[i][j] = ncLittleEndian16(_packet + 6 + (i * 3 + j) * 2);
                }
            }
            break;

        default:
            osErrorDisplay("Unsupported packet type");
            return FALSE;
    }

    return TRUE;
}

/*****************************************************************************/

BOOL ncStopStreaming(void) {
    _streaming = FALSE;
    _packetReady = FALSE;

    if (!_connected) {
        osErrorDisplay("Not connected");
        return FALSE;
    }

    /* Send command (NavChip sends no response if streaming) */
    if (!_issuePing(FALSE)) {
        return FALSE;
    }

    /* Wait for packets to stop arriving */
    osTimeWait(NC_TIMEOUT_RESPONSE);

    return TRUE;
}

/*****************************************************************************/

INT16 ncLittleEndian16(UINT8 b[]) { return (b[1] << 8) | b[0]; }

INT32 ncLittleEndian32(UINT8 b[]) { return (b[3] << 24) | (b[2] << 16) | (b[1] << 8) | b[0]; }

/*****************************************************************************/

BOOL ncValidatePacketId(UINT8 id0, UINT8 id1) {
    /* Wrap? */
    if (id0 == 255 && id1 == 0) {
        return TRUE;
    }
    /* Sequential */
    else if (id1 - id0 == 1) {
        return TRUE;
    }

    /* Error */
    return FALSE;
}
