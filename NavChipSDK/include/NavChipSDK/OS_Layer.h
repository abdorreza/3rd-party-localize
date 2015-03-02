/******************************************************************************
** InterSense NavChip Developer Kit
**
** The InterSense NavChip Developer Kit sample code is considered proprietary
** and confidential. The NavChip Developer Kit sample code is available for
** use by customers who have signed the InterSense NDA and otherwise shall not
** be distributed without the written consent of InterSense Incorporated.
**
** Filename: OS_Layer.h
** Modified: 14 Dec 2009
**
** Comments: Operating system interface functions for serial port
**           communication, timer, etc.
**
**           The sample source code in this project is provided for use by
**           InterSense customers with the limitations and restrictions as
**           defined above. It is supplied without any warranty or implied
**           suitability or fitness for any particular purpose.
******************************************************************************/

#ifndef _INC_OS_Layer_h
#define _INC_OS_Layer_h

#ifdef __cplusplus
extern "C" {
#endif

/* If defined, display more error messages */
/*#define _VERBOSE
*/

/* Boolean values */
#define TRUE 1
#define FALSE 0

/* Type definitions */
typedef int BOOL;
typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef short INT16;
typedef unsigned int UINT32;
typedef int INT32;
typedef double REAL;

/* Determines number of elements in given array */
#define NELEM(array) (sizeof(array) / sizeof(array[0]))

/******************************************************************************
***************************** Serial port access ******************************
******************************************************************************/

/* Highest valid port number (zero-based) */
#define OS_MAX_PORT_NUMBER 31

/******************************************************************************
** osComPortOpen - Open serial port (default 115200 bps, 8 data bits, 1 stop
**                 bit, flow control off)
**
** Inputs:
**   portNumber - zero-based port number
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortOpen(int portNumber);

/******************************************************************************
** osComPortClose - Close serial port
**
** Inputs:
**   portNumber - zero-based port number
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortClose(int portNumber);

/******************************************************************************
** osComPortFlush - Flush any buffered bytes from serial port
**
** Inputs:
**   portNumber - zero-based port number
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortFlush(int portNumber);

/******************************************************************************
** osComPortSetRate - Set baud rate for serial port
**
** Inputs:
**   portNumber - zero-based port number
**   rate       - baud rate in bits per second
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortSetRate(int portNumber, int rate);

/******************************************************************************
** osComPortRead - Read bytes from serial port. This function is non-blocking
**                 and returns immediately after reading zero or more bytes
**                 as indicated by rcvCount (up to a maximum of reqCount)
**
** Inputs:
**   portNumber - zero-based port number
**   reqCount   - requested number of bytes to read
**
** Outputs:
**   buffer - buffer for incoming bytes
**   rcvCount  - number of bytes received
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortRead(int portNumber, UINT8 buffer[], int reqCount, int *rcvCount);

/******************************************************************************
** osComPortWrite - Write bytes to serial port
**
** Inputs:
**   portNumber - zero-based port number
**   buffer     - buffer of outgoing bytes
**   count      - number of bytes to write
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osComPortWrite(int portNumber, UINT8 buffer[], int count);

/******************************************************************************
******************************* Timer access **********************************
******************************************************************************/

/******************************************************************************
** osTimeGet - Get current system time
**
** Inputs/Outputs:
**   none
**
** Returns:
**   Time in ms (note that value will overflow every 50 days)
******************************************************************************/
UINT32 osTimeGet(void);

/******************************************************************************
** osTimeGetElapsed - Get elapsed time
**
** Inputs:
**   t0 - time to measure from
**
** Outputs:
**   none
**
** Returns:
**   Elapsed time since t0 in ms
******************************************************************************/
UINT32 osTimeGetElapsed(UINT32 t0);

/******************************************************************************
** osTimeWait - Sleeps for specified time
**
** Inputs
**   delay - time (ms) to block
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osTimeWait(UINT32 delay);

/******************************************************************************
*********************************** Other *************************************
******************************************************************************/

/******************************************************************************
** osConsoleClear - Clear screen
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osConsoleClear(void);

/******************************************************************************
** osConsoleHome - Home cursor
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osConsoleHome(void);

/******************************************************************************
** osKbhit - Checks for a keypress without blocking
**
** Inputs/Outputs:
**   none
**
** Returns:
**   TRUE if keypress else FALSE
******************************************************************************/
BOOL osKbhit(void);

/******************************************************************************
** osErrorDisplay - Display error message
**
** Inputs:
**   message - error message to display (NULL for auto-generated message)
**
** Outputs:
**   none
**
** Returns:
**   TRUE if successful, FALSE on failure
******************************************************************************/
BOOL osErrorDisplay(const char *message);

#ifdef __cplusplus
}
#endif

#endif /* _INC_OS_Layer_h */
