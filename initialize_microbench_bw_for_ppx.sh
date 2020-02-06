git submodule update --init

sed -i -e "s|p520_max_sg280l|p520_max_sg280h|g" ./CMakeLists.txt
# -ie はNG．https://bit.ly/2R9Td7y

cat ./CMakeLists.txt | grep "p520_max_sg280h" \
&& echo -e "\e[32;1m p520_max_sg280h Found . OK. \e[m " \
|| echo -e "\e[31;1m p520_max_sg280h Not Found.\e[m  Edit your CMakeLists.txt"


echo "Edit ./microbenchmarks/host/bandwidth_benchmark.cpp "
sed -i -e "s|fpga = rank % 2|fpga = rank % 1|g" ./microbenchmarks/host/bandwidth_benchmark.cpp
cat ./microbenchmarks/host/bandwidth_benchmark.cpp | grep "fpga = rank % 1" \
&& echo -e "\e[32;1m Num of FPGA = 1. OK. \e[m " \

echo "Edit microbenchmarks/kernels/bandwidth.json"
cat << 'EOF' > microbenchmarks/kernels/bandwidth.json
{
    "fpgas": {
      "ppx2-02:acl0": "bandwidth_0",
      "ppx2-03:acl0": "bandwidth_1"
    },
    "connections": {
      "ppx2-02:acl0:ch1": "ppx2-03:acl0:ch0"
    }
  }
EOF
cat microbenchmarks/kernels/bandwidth.json
 

