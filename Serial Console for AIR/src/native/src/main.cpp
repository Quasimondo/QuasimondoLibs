#include "ofSerial.h"
#include "stdio.h"
#include "signal.h"
#include "windows.h"
#include "fcntl.h"

#define SERIAL_IN_BUFFER_SIZE 32768
#define SERIAL_OUT_BUFFER_SIZE 32768



void terminalHandler( int sig ) { fclose( stdout ); exit(1); }

int main(){

    _setmode( _fileno( stdin ), _O_BINARY );
    _setmode( _fileno( stdout ), _O_BINARY );

    signal( SIGABRT, terminalHandler );
    signal( SIGTERM, terminalHandler );
    signal( SIGINT, terminalHandler );

    ofSerial serial;

    serial.enumerateDevices();
    cout << "\nEnter Device Index: ";
    flush(cout);

    char portIndex [256];
    gets (portIndex);

    cout << "Enter Baud Rate: ";
    char baud [10];
    gets (baud);

    if ( serial.setup(atoi(portIndex), atoi(baud)) )
    {
        cout << "Serial connection established\n\nEnter 'a' to check available bytes\nEnter 'g' to get all available bytes\nEnter 's' to send data, followed by data on the next line\nEnter 'x' to exit\n";
    } else {
        cout << "Error: Serial connection failed\n";
        return 0;
    }

    flush(cout);

    int cnt;
    unsigned char byte;
    char command;
    char serialBufferIn[SERIAL_IN_BUFFER_SIZE];
    char serialBufferOut[SERIAL_OUT_BUFFER_SIZE];

    size_t lenInMax = SERIAL_IN_BUFFER_SIZE, lenIn = 0;

    while ( !feof( stdin ) )
    {
        while ( lenIn < lenInMax && serial.readBytes( &byte, 1) > 0)
        {
            serialBufferIn[lenIn++] = byte;
        }

        gets(&command);
        if ( ferror( stdin ))
        {
            cout << "End of File\n";
            flush(cout);
            serial.close();
            exit(1);
        }
        if ( command == 'g' )
        {
            if ( lenIn > 0 )
            {
                fwrite( &serialBufferIn, sizeof( char ), lenIn, stdout );
                lenIn = 0;
                flush(cout);
            }
        } else if ( command == 'a' )
        {

            char buf[24];
            _ultoa(lenIn,buf,10);
            string s = buf;
            cout << s+'\n';
            flush(cout);


        } else if ( command == 's' )
        {
           gets(serialBufferOut);
           serial.writeBytes( reinterpret_cast<unsigned char*>(serialBufferOut), strlen( serialBufferOut ) );
           if ( serialBufferOut[strlen( serialBufferOut )-1] != 0x0d ) serial.writeByte( 0xd );
           char buf[24];
            _ultoa(strlen( serialBufferOut ),buf,10);
            string s = buf;

            //This is more of a hack, but it seems to work - we have to wait for a bit so the arduino can react
            Sleep(50 + strlen( serialBufferOut ) );

         } else if ( command == 'x' )
        {
            serial.close();
            exit(0);

        } else {
            cout << "Unknown Command\n";
            flush(cout);
        }
    }

    return 0;
}




