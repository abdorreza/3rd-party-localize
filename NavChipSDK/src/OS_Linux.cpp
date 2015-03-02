/******************************************************************************
** InterSense NavChip Developer Kit
**
** The InterSense NavChip Developer Kit sample code is considered proprietary
** and confidential. The NavChip Developer Kit sample code is available for
** use by customers who have signed the InterSense NDA and otherwise shall not
** be distributed without the written consent of InterSense Incorporated.
**
** Filename: OS_Linux.c
** Modified: 14 Dec 2009
**
** Comments: Implementation for Linux.
**
**           For serial ports, the first half of the port numbers are mapped
**           to ports ttyS0, ttyS1, etc. The rest are mapped to ttyUSB0,
**           ttyUSB1, etc.
**
**           See also osLayer.h for public function descriptions.
**
**           The sample source code in this project is provided for use by
**           InterSense customers with the limitations and restrictions as
**           defined above. It is supplied without any warranty or implied
**           suitability or fitness for any particular purpose.
******************************************************************************/

#if TARGET_OS_MAC_OSX
#define UNIX
#else
#error OS is not supported
#endif

#ifndef UNIX
#error This module for use with UNIX-compatible environments only
#endif

#include <stdio.h>
#include <sys/termios.h>
#include <sys/time.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <NavChipSDK/OS_Layer.h>

/*define missing speeds*/

#ifndef B460800
#define B460800 460800
#endif

#ifndef B921600
#define B921600 921600
#endif

/******************************************************************************
***************************** Serial port access ******************************
******************************************************************************/

#define MAX_COM_PORTS (OS_MAX_PORT_NUMBER + 1)

typedef struct {
    char name[100];
    int handle;
} ComPort;

static ComPort _comPort[MAX_COM_PORTS];

/******************************************************************************
** _comPortGet - Get port object corresponding to given port number
**
** Inputs:
**   portNumber - zero-based port number
**
** Outputs:
**   none
**
** Returns:
**   pointer to port object (NULL if none)
******************************************************************************/
static ComPort *_comPortGet(int portNumber) {
    ComPort *port = NULL;
    BOOL ok = portNumber >= 0 && portNumber < MAX_COM_PORTS;

    if (!ok) {
        osErrorDisplay("Supplied port number is out of range");
    } else {
        port = _comPort + portNumber;
    }
    return port;
}

/*****************************************************************************/

BOOL osComPortOpen(int portNumber) {
    ComPort *port;

    /* Get port */
    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    osComPortClose(portNumber);

    /* Standard port */
    if (portNumber < MAX_COM_PORTS / 2) {
        //        sprintf( port->name, "/dev/ttyS%d", portNumber );
        sprintf(port->name, "/dev/tty.SLAB_USBtoUART");

    }
    /* USB port */
    else {
        sprintf(port->name, "/dev/ttyUSB%d", portNumber - MAX_COM_PORTS / 2);
    }

    /* Open serial port */
    port->handle = open(port->name, O_RDWR | O_NONBLOCK | O_NOCTTY);

    /* Port cannot be opened? */
    if (port->handle <= 0) {
#ifdef _VERBOSE
        osErrorDisplay("Unable to open serial port");
#endif
        port->handle = 0;
        return FALSE;
    }

    return TRUE;
}

/*****************************************************************************/

BOOL osComPortClose(int portNumber) {
    ComPort *port;

    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    if (port->handle != 0) {
        close(port->handle);
        port->handle = 0;
    }
    return TRUE;
}

/*****************************************************************************/

BOOL osComPortFlush(int portNumber) {
    ComPort *port;

    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    if (port->handle == 0) {
        osErrorDisplay("Port is not open");
        return FALSE;
    }

    if (tcflush(port->handle, TCIFLUSH) == -1) {
        osErrorDisplay("Failed to flush serial port");
        return FALSE;
    }

    return TRUE;
}

/*****************************************************************************/

BOOL osComPortSetRate(int portNumber, int rate) {
    ComPort *port;
    struct termios tios;
    int baud;

    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    if (port->handle == 0) {
        osErrorDisplay("Port is not open");
        return FALSE;
    }

    if (tcgetattr(port->handle, &tios) == -1) {
#ifdef _VERBOSE
        osErrorDisplay("Failed to get state for serial port");
#endif
        return FALSE;
    }

    /* Ignore parity errors */
    tios.c_iflag = IGNBRK | IGNPAR;

    /* Raw input */
    tios.c_lflag = 0;
    tios.c_oflag = 0;

    tios.c_cflag = (CREAD | CLOCAL | HUPCL | CS8);

    tios.c_cc[VEOL] = '\000';
    tios.c_cc[VEOL2] = '\000';
    tios.c_cc[VERASE] = '\000';
    tios.c_cc[VKILL] = '\000';
    tios.c_cc[VMIN] = 0;
    tios.c_cc[VTIME] = 0; /* ie non-blocking */

    switch (rate) {
        case 9600:
            baud = B9600;
            break;
        case 19200:
            baud = B19200;
            break;
        case 38400:
            baud = B38400;
            break;
        case 115200:
            baud = B115200;
            break;
        case 230400:
            baud = B230400;
            break;
        case 460800:
            baud = B460800;
            break;
        case 921600:
            baud = B921600;
            break;
        default:
            osErrorDisplay("Unsupported rate specified");
            return FALSE;
    }

    cfsetospeed(&tios, baud);
    cfsetispeed(&tios, baud);

    if (tcsetattr(port->handle, TCSAFLUSH, &tios) == -1) {
#ifdef _VERBOSE
        osErrorDisplay("Failed to set attributes for serial port");
#endif
        return FALSE;
    }

    return TRUE;
}

/*****************************************************************************/

BOOL osComPortRead(int portNumber, UINT8 buffer[], int reqCount, int *rcvCount) {
    ComPort *port;
    size_t status;
    int i;

    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    if (port->handle == 0) {
        osErrorDisplay("Port is not open");
        return FALSE;
    }
    *rcvCount = 0;

    /* Read available bytes up to requested maximum */
    for (i = 0; i < reqCount; i++) {
        status = read(port->handle, buffer + *rcvCount, 1);

        if (status > 0) {
            (*rcvCount)++;
        } else if (status == 0) {
            break;
        } else {
            osErrorDisplay("Read failed");
            return FALSE;
        }
    }

    return TRUE;
}

/*****************************************************************************/

BOOL osComPortWrite(int portNumber, UINT8 buffer[], int count) {
    ComPort *port;

    if (!(port = _comPortGet(portNumber))) {
        return FALSE;
    }

    if (port->handle == 0) {
        osErrorDisplay("Port is not open");
        return FALSE;
    }

    if (write(port->handle, buffer, count) == -1) {
        osErrorDisplay("Write to serial port failed");
        return FALSE;
    }

    return TRUE;
}

/******************************************************************************
******************************* Timer access **********************************
******************************************************************************/

UINT32 osTimeGet(void) {
    static BOOL _timeInitialized = FALSE;
    static struct timeval t;
    static struct timezone tz;
    static unsigned long initialTime;
    UINT32 time;

    /* Get initial time on the first time through */
    if (!_timeInitialized) {
        gettimeofday(&t, &tz);
        initialTime = t.tv_sec;
        _timeInitialized = TRUE;
    }

    /* Subtract the initial time from current time.*/
    /* Output value (ms) will overflow after 50 days */
    gettimeofday(&t, &tz);
    time = (UINT32)((t.tv_sec - initialTime) * 1000 + t.tv_usec / 1000);

    return time;
}

/*****************************************************************************/

UINT32 osTimeGetElapsed(UINT32 t0) {
    UINT32 t1 = osTimeGet();

    /* If timer overflows, set first value to zero (crude but safe) */
    if (t1 < t0) {
        t0 = 0;
    }

    return t1 - t0;
}

/*****************************************************************************/

BOOL osTimeWait(UINT32 delay) {
    usleep(delay * 1000);
    return TRUE;
}

/******************************************************************************
*********************************** Other *************************************
******************************************************************************/
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
BOOL osConsoleClear(void) { return write(1, "\E[H\E[2J", 7) == 1; }

/*****************************************************************************/

BOOL osConsoleHome(void) { return write(1, "\E[H", 3) == 1; }
#pragma GCC diagnostic pop
/*****************************************************************************/

/* NOTE: This implementation requires that osKbhit() be called until it*/
/* returns TRUE in order to properly restore terminal I/O settings */

BOOL osKbhit(void) {
    static BOOL initialized = FALSE;
    static struct termios initSettings;
    static struct termios settings;
    unsigned char c;
    size_t nread;

    if (!initialized) {
        tcgetattr(0, &initSettings);
        settings = initSettings;
        settings.c_lflag &= ~ICANON;
        settings.c_lflag &= ~ECHO;
        settings.c_lflag &= ~ISIG;
        settings.c_cc[VMIN] = 1;
        settings.c_cc[VTIME] = 0;
        tcsetattr(0, TCSANOW, &settings);
        initialized = TRUE;
    }
    settings.c_cc[VMIN] = 0;
    tcsetattr(0, TCSANOW, &settings);
    nread = read(0, &c, 1);
    settings.c_cc[VMIN] = 1;
    tcsetattr(0, TCSANOW, &settings);

    if (nread == 1) {
        tcsetattr(0, TCSANOW, &initSettings);
        return TRUE;
    }
    return FALSE;
}

/*****************************************************************************/

BOOL osErrorDisplay(const char *message) {
    /* Display supplied message, if any */
    if (message != NULL) {
        puts(message);
        printf("\n");
    }
    /* No message supplied */
    else {
        printf("Unknown error occurred\n");
    }

    return TRUE;
}
