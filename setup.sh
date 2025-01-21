#!/bin/bash

echo "### setup start ###"
mkdir -p ./autoware/autoware_map

echo ""
echo "### install require pkg ###"

echo ""
echo "### model file download ###"
./docker/model.sh

echo ""
echo "### git pull ###"
git clone git@github.com:inwoong32/Autoware_FT.git ./autoware/src

echo ""
echo "### docker image build ###"
./build.sh
cd ..

echo ""
echo "### Net setting ###"
echo '## Autoware Net setting' >> ~/.bashrc
echo '' >> ~/.bashrc
echo 'if [ ! -e /tmp/cycloneDDS_configured ]; then' >> ~/.bashrc
echo '    sudo sysctl -w net.core.rmem_max=2147483647' >> ~/.bashrc
echo '    sudo sysctl -w net.ipv4.ipfrag_time=3' >> ~/.bashrc
echo '    sudo sysctl -w net.ipv4.ipfrag_high_thresh=134217728     # (128 MB)' >> ~/.bashrc
echo '    sudo ip link set lo multicast on' >> ~/.bashrc
echo '    touch /tmp/cycloneDDS_configured' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
echo '' >> ~/.bashrc

cp docker/cyclonedds.xml autoware/.cyclonedds.xml

echo ""
echo "### setup finish ###"
echo ""
echo "#############################################"
echo "### You can run docker for ./run.sh aw:v0 ###"