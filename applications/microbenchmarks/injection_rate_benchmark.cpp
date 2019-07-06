/**
    Injection rate  benchmark
    A sender, push message of size 1 to a receiver.
    The average injection rate is computed.

    The FPGA program is written as MPMD with two programs, one for the sender
    and one for the receiver. The sender is rank 0, while the receiver can
    be any other rank between 1 and NUM_RANKS. For the intermediate ranks,
    the program for rank1 is loaded, in order to guarantee the routing
    of the transient channels.


 */

#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <unistd.h>
#include <cmath>
#include "../../include/utils/ocl_utils.hpp"
#include "../../include/utils/utils.hpp"
#include "codegen_scaling/smi-host-0.h"
#define ROUTING_DIR "applications/microbenchmarks/injection_rate_codegen/"

using namespace std;
int main(int argc, char *argv[])
{

    CHECK_MPI(MPI_Init(&argc, &argv));

    //command line argument parsing
    if(argc<11)
    {
        cerr << "Ingestion rate " <<endl;
        cerr << "Usage: "<< argv[0]<<"-m <emulator/hardware> -b <binary file> -n <length> -r <rank on which run the receiver> -i <number of runs> "<<endl;
        exit(-1);
    }
    int n;
    int c;
    std::string program_path;
    int rank;
    bool emulator;
    char recv_rank;
    int fpga,runs;
    while ((c = getopt (argc, argv, "m:n:b:r:i:")) != -1)
        switch (c)
        {
            case 'n':
                n=atoi(optarg);
                break;
            case 'm':
            {
                std::string mode=std::string(optarg);
                if(mode!="emulator" && mode!="hardware")
                {
                    cerr << "Mode: emulator or hardware"<<endl;
                    exit(-1);
                }
                emulator=mode=="emulator";
                break;
            }
            case 'b':
                program_path=std::string(optarg);
                break;
            case 'i':
                runs=atoi(optarg);
                break;
            case 'r':
                recv_rank=atoi(optarg);
                break;
            default:
                cerr << "Usage: "<< argv[0]<<"-m <emulator/hardware> -b <binary file> -n <length> -r <rank on which run the receiver> -i <number of runs> "<<endl;
                exit(-1);
        }

    cout << "Performing ingestion rate test with "<<n<<" elements"<<endl;
    int rank_count;
    CHECK_MPI(MPI_Comm_size(MPI_COMM_WORLD, &rank_count));
    CHECK_MPI(MPI_Comm_rank(MPI_COMM_WORLD, &rank));
    fpga = rank % 2; // in this case is ok, pay attention
    std::cout << "Rank: " << rank << " out of " << rank_count << " ranks" << std::endl;
    if(!emulator)
    {
        if(rank==0)
            program_path = replace(program_path, "<rank>", std::string("0"));
        else //any rank other than 0
            program_path = replace(program_path, "<rank>", std::string("1"));
    }
    else//for emulation
        program_path = replace(program_path, "<rank>", std::to_string(rank));

    char hostname[256];
    gethostname(hostname, 256);
    std::cout << "Rank" << rank<<" executing on host:" <<hostname << " program: "<<program_path<<std::endl;

    cl::Platform  platform;
    cl::Device device;
    cl::Context context;
    cl::Program program;
    std::vector<cl::Buffer> buffers;
    SMI_Comm comm=SmiInit(rank, rank_count, program_path.c_str(), ROUTING_DIR, platform, device, context, program, fpga,buffers);
    cl::Kernel kernel;
    cl::CommandQueue queue;
    IntelFPGAOCLUtils::createCommandQueue(context,device,queue);
    IntelFPGAOCLUtils::createKernel(program,"app",kernel);

    std::vector<double> times;
    if(rank==0)
    {
        kernel.setArg(0,sizeof(int),&n);
        kernel.setArg(1,sizeof(char),&recv_rank);
        kernel.setArg(2,sizeof(SMI_Comm),&comm);
    }
    else
    {
        kernel.setArg(0,sizeof(int),&n);
        kernel.setArg(1,sizeof(SMI_Comm),&comm);
    }
    for(int i=0;i<runs;i++)
    {
        cl::Event event;
        CHECK_MPI(MPI_Barrier(MPI_COMM_WORLD));
        timestamp_t start=current_time_usecs();

        if(rank==0 || rank==recv_rank)
        {
            queue.enqueueTask(kernel,nullptr,&event);
            queue.finish();
        }
        timestamp_t end=current_time_usecs();

        CHECK_MPI(MPI_Barrier(MPI_COMM_WORLD));
        if(rank==0)
        {
            ulong end, start;
            event.getProfilingInfo<ulong>(CL_PROFILING_COMMAND_START,&start);
            event.getProfilingInfo<ulong>(CL_PROFILING_COMMAND_END,&end);

            double time= (double)((end-start)/1000.0f);
            times.push_back(time);
        }
    }
    if(rank==0)
    {   //compute means
        double mean=0;
        for(auto t:times)
            mean+=t;
        mean/=runs;
        //report the mean in usecs
        double stddev=0;
        for(auto t:times)
            stddev+=((t-mean)*(t-mean));
        stddev=sqrt(stddev/runs);
        double conf_interval_99=2.58*stddev/sqrt(runs);
        cout << "-------------------------------------------------------------------"<<std::endl;
        cout << "Computation time (usec): " << mean << " (sttdev: " << stddev<<")"<<endl;
        cout << "Conf interval 99: "<<conf_interval_99<<endl;
        cout << "Conf interval 99 within " <<(conf_interval_99/mean)*100<<"% from mean" <<endl;
        cout << "-------------------------------------------------------------------"<<std::endl;

        //save the info into output file
        std::ostringstream filename;
        filename << "ingestion_rate_" << n << ".dat";
        std::cout << "Saving info into: "<<filename.str()<<std::endl;
        ofstream fout(filename.str());
        fout << "#Ingestion rate benchnmark: sending  "<<n<<" messages of size 1" <<std::endl;
        fout << "#Average Computation time (usecs): "<<mean<<endl;
        fout << "#Standard deviation (usecs): "<<stddev<<endl;
        fout << "#Confidence interval 99%: +- "<<conf_interval_99<<endl;
        fout << "#Execution times (usecs):"<<endl;
        for(auto t:times)
            fout << t << endl;
        fout.close();
    }
    CHECK_MPI(MPI_Finalize());

}
