#!/usr/bin/env python3

import datetime, time
import re
import subprocess
from subprocess import Popen

class color:
    def _wrap_with(code):
        def inner(text, bold=False):
            c = code
            if bold:
                c = "1;%s" % c
            return "\033[%sm%s\033[0m" % (c, text)
        return inner  
    red     = _wrap_with('31')
    green   = _wrap_with('32')
    yellow  = _wrap_with('33')
    blue    = _wrap_with('34')
    magenta = _wrap_with('35')
    cyan    = _wrap_with('36')
    white   = _wrap_with('37')

class Nqsv:
    def __init__(self):
        self.times=0
    
    def qstat(self):
        if (self.times < 3):
            self.times += 1
            return self.running()
        else:
            self.times = 0
            return self.done()
        
    def running(self):
        string="""RequestID       ReqName  UserName Queue     Pri STT S   Memory      CPU   Elapse R H M Jobs
--------------- -------- -------- -------- ---- --- - -------- -------- -------- - - - ----
444211.nqsv     SMI_Qsub kashino  fpga        0 RUN -  925.64M     0.97       23 N Y Y    1"""
        return string
    def done(self):
        string=""
        return string



def testQstat(jobID, elapsed_limit=10):
    nqsv = Nqsv()

    timeout = time.time() + elapsed_limit   # elapsed_limit (sec) from now

    duration = 5
    print(time.time(), " ", timeout)
    while True:
        output = nqsv.qstat()
        #print(time.time(), " ", timeout)
        if (output.find(jobID) == -1):
            print(color.red('not found'))
            return jobID
        elif (time.time() > timeout):
            print(color.red('timeout'))
            return -1
        else:
            print(output)
            print(color.green('found'))
        time.sleep(duration)



def execCommand():
    try:
        mock = "Request 444211.nqsv submitted to queue: fpga."
        p = Popen(["echo",mock], 
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        output, errors = p.communicate()
        print(output)
    except:
        print((color.red('%s') + ': failed') % "command")
        exit(1)
    return output

def main():
    print((color.green('%s') + ': this is color string test') % "green")
    jobID = re.sub("\\D", "", execCommand() )
    print(jobID)
    testQstat(jobID)



if __name__ == '__main__':
    print(datetime.datetime.now().strftime('Start: %Y-%m-%d %H:%M:%S'))
    main()    
    print(datetime.datetime.now().strftime('End: %Y-%m-%d %H:%M:%S'))
