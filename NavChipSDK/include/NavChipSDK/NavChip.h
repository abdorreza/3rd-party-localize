/******************************************************************************
** InterSense NavChip Developer Kit
**
** The InterSense NavChip Developer Kit sample code is considered proprietary
** and confidential. The NavChip Developer Kit sample code is available for
** use by customers who have signed the InterSense NDA and otherwise shall not
** be distributed without the written consent of InterSense Incorporated.
**
** Filename: NavChip.h
** Modified: 14 Dec 2009
**
** Comments: NavChip interface layer for basic device interactions. This
**           implementation is capable of connecting to a single NavChip
**           only. This layer utilizes the OS interface layer.
**
**           The sample source code in this project is provided for use by
**           InterSense customers with the limitations and restrictions as
**           defined above. It is supplied without any warranty or implied
**           suitability or fitness for any particular purpose.
******************************************************************************/

#ifndef _INC_NavChip_h
#define _INC_NavChip_h

#include "OS_Layer.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Register addresses (see NavChip Interface Control Document for details) */
#define NC_REG_DEVICE_TYPE 0
#define NC_REG_FIRMWARE_VERSION 1 /* 2 bytes */
#define NC_REG_SERIAL_NUMBER 4    /* 3 bytes */
#define NC_REG_NAVCHIP_TYPE 7
#define NC_REG_BAUD_RATE_DIVISOR 14
#define NC_REG_DATA_RATE_DIVISOR 15
#define NC_REG_PACKET_TYPE 16
#define NC_REG_ENABLE_FLAGS 17
#define NC_REG_WORKING_STATE 18
#define NC_REG_TEMPERATURE 26  /* 2 bytes */
#define NC_REG_CAL_REVISION 55 /* 2 bytes */

/* Maxima */
#define NC_MAX_BAUD_RATE 921600 /* bits/s */
#define NC_MAX_DATA_RATE 1000   /* packets/s */

/* NavChip device type */
#define NC_DEVICE_TYPE 22 /* register 0 */

/* Discrete flag byte masks */
#define NC_FLAG_E1 0x80 /* event 1 */
#define NC_FLAG_E2 0x40 /* event 2 */
#define NC_FLAG_D 0x20  /* reserved */
#define NC_FLAG_S 0x10  /* CR bit */
#define NC_FLAG_F 0x08  /* fault */
#define NC_FLAG_R 0x04  /* reserved */
#define NC_FLAG_I 0x03  /* mag index */

/* Multiplicative scale factors to convert data packet values in
 ncPacketDataType from fixed point to floating point */
#define NC_SCALE_DTC 0.1f            /* delta theta (mrad), compact packets 1-2 */
#define NC_SCALE_DT 6.25e-3f         /* delta theta (mrad), other packet types */
#define NC_SCALE_DVC 2.5e-3f         /* delta V (m/s), compact packets 1-2 */
#define NC_SCALE_DV 39.0625e-6f      /* delta V (m/s), other packet types */
#define NC_SCALE_MAG 0.25e-3f        /* magnetometer (G) */
#define NC_SCALE_EULER 0.1e-3f       /* euler angles (rad) */
#define NC_SCALE_QUAT (1 / 32768.0f) /* quaternion */
#define NC_SCALE_ROT (1 / 32768.0f)  /* rotation matrix */

/* Other multiplicative scale factors to convert register values
 from fixed point to floating point */
#define NC_SCALE_TEMP 0.05f /* temperature (deg C) */

/* NavChip data packet type.
 The first four items are valid for packet types 1-9.
 The other items are available with certain packet types only.
 Use NC_SCALE definitions to scale values to floating point.
 See NavChip Interface Control Document for details */
typedef struct {
    UINT8 packetType;    /* packet type 1-9 supported by sample code */
    UINT8 packetId;      /* packet ID (0-255) */
    UINT8 flags;         /* discrete flag byte, decode w/NC_FLAG masks */
    INT16 timestamp;     /* time since last integration (us) */
    INT16 deltaTheta[3]; /* incremental rotation [x y z] */
                         /* scale w/NC_SCALE_DTC for packet types 1-2 */
                         /* else scale w/NC_SCALE_DT */
    INT16 deltaV[3];     /* incremental velocity change [x y z] */
                         /* scale w/NC_SCALE_DVC for packet types 1-2 */
                         /* else scale w/NC_SCALE_DV */
    INT16 mag;           /* magnetometer value for axis I, scale w/NC_SCALE_MAG */
    INT16 euler[3];      /* euler angles [roll pitch yaw], scale w/NC_SCALE_EULER */
    INT16 quat[4];       /* quaternion [q0 q1 q2 q3], scale w/NC_SCALE_QUAT */
    INT16 rot[3][3];     /* 3x3 rotation matrix, scale w/NC_SCALE_ROT */
} ncPacketDataType;

/******************************************************************************
** ncOpen - Automatically detects NavChip on available serial ports
**
** Inputs:
**   none
**
** Outputs:
**   port    - port number (zero-based)
**   address - NavChip address
**   rate    - baud rate (bps)
**
** Returns:
**   TRUE if NavChip detected successfully, FALSE otherwise
******************************************************************************/
BOOL ncOpen(int *port, int *address, int *rate);

/******************************************************************************
** ncClose - Closes serial port and releases resources
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncClose(void);

/******************************************************************************
** ncGetRegister - Reads NavChip configuration register
**
** Inputs:
**   regAddress - start address of register (0-255)
**   count      - number of contiguous bytes to get (1-4)
**
** Outputs:
**   value - register byte(s) in little endian order
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncGetRegister(UINT8 regAddress, int count, UINT8 value[]);

/******************************************************************************
** ncSetRegister1/M - Writes NavChip configuration register (single/multi byte)
**
** Inputs:
**   regAddress - start address of register (0-255)
**   count      - number of contiguous bytes to set (1-4)
**   value      - register byte(s) in little endian order
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncSetRegister1(UINT8 regAddress, UINT8 value);
BOOL ncSetRegisterM(UINT8 regAddress, int count, const UINT8 value[]);

/******************************************************************************
** ncStartStreaming - Starts streaming mode. While streaming, data may be read
**                    with ncReadPacket() and ncGetData(). Streaming must be
**                    stopped with ncStopStreaming() before other operations
**                    are allowed
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncStartStreaming(void);

/******************************************************************************
** ncReadPacket - Reads received packet (non-blocking). Streaming must be on
**
** Inputs:
**   none
**
** Outputs:
**   ready - TRUE if packet has been read and data can be accessed using
**           ncGetData(). FALSE if packet is not yet received
**
** Returns:
**   TRUE if successful (ready may be TRUE or FALSE), FALSE on failure (eg
**   timeout or invalid packet)
******************************************************************************/
BOOL ncReadPacket(BOOL *ready);

/******************************************************************************
** ncGetData - Retrieve data for packet previously read with ncReadPacket()
**
** Inputs:
**   none
**
** Outputs:
**   data - packet data
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncGetData(ncPacketDataType *data);

/******************************************************************************
** ncStopStreaming - Cancels streaming mode
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL ncStopStreaming(void);

/******************************************************************************
** ncLittleEndian16/32 - Packs little endian bytes into 16- or 32-bit word.
**                       Use these functions to form words out of byte arrays
**                       obtained from ncGetRegister()
**
** Inputs
**   b[] - bytes in order of least to most significant (2 bytes for 16-bit
**         and 4 bytes for 32-bit)
**
** Outputs:
**   none
**
** Returns:
**   16- or 32-bit word
******************************************************************************/
INT16 ncLittleEndian16(UINT8 b[]);
INT32 ncLittleEndian32(UINT8 b[]);

/******************************************************************************
** ncValidatePacketId - Checks if two data packet IDs are sequential
**
** Inputs
**   id0 - first packet ID
**   id1 - second packet ID
**
** Outputs:
**   none
**
** Returns:
**   TRUE if packet IDs are ok, else FALSE
******************************************************************************/
BOOL ncValidatePacketId(UINT8 id0, UINT8 id1);

#ifdef __cplusplus
}
#endif

#endif /* _INC_NavChip_h */
