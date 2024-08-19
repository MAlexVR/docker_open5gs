# Internet, VoLTE, SMS and IPTV environment with docker Open5GS

Docker files to build and run open5gs in a docker, this is a fork version of https://github.com/herlesupreeth/docker_open5gs and https://github.com/s5uishida/docker_open5gs_volte_sms_config

# Docker Open5GS

![image](https://user-images.githubusercontent.com/6804880/162587777-c0363a18-8296-474e-bc32-a69b87d9bae1.png)

# 4G/5G NSA Core

The Open5GS 4G/ 5G NSA Core contains the following components:

- MME - Mobility Management Entity
- HSS - Home Subscriber Server
- PCRF - Policy and Charging Rules Function
- SGWC - Serving Gateway Control Plane
- SGWU - Serving Gateway User Plane
- PGWC/SMF - Packet Gateway Control Plane / (component contained in Open5GS SMF)
- PGWU/UPF - Packet Gateway User Plane / (component contained in Open5GS UPF)

The core has two main planes: the control plane and the user plane. These are physically separated in Open5GS as CUPS (control/ user plane separation) is implemented.

The MME is the main control plane hub of the core. It primarily manages sessions, mobility, paging and bearers. It links to the HSS, which generates SIM authentication vectors and holds the subscriber profile; and also to the SGWC and PGWC/SMF, which are the control planes of the gateway servers. All the eNBs in the mobile network (4G basestations) connect to the MME. The final element of the control plane is the PCRF, which sits in-between the PGWC/SMF and the HSS, and handles charging and enforces subscriber policies.

The user plane carries user data packets between the eNB/ NSA gNB (5G NSA basestations) and the external WAN. The two user plane core components are the SGWU and PGWU/UPF. Each of these connect back to their control plane counterparts. eNBs/ NSA gNBs connect to the SGWU, which connects to the PGWU/UPF, and on to the WAN. By having the control and user planes physically separated like this, it means you can deploy multiple user plane servers in the field (eg somewhere with a high speed Internet connection), whilst keeping control functionality centralised. This enables support of MEC use cases, for example.

All of these Open5GS components have config files. Each config file contains the component’s IP bind addresses/ local Interface names and the IP addresses/ DNS names of the other components it needs to connect to.

# 5G SA Core

The Open5GS 5G SA Core contains the following functions:

- AMF - Access and Mobility Management Function
- SMF - Session Management Function
- UPF - User Plane Function
- AUSF - Authentication Server Function
- NRF - NF Repository Function
- UDM - Unified Data Management
- UDR - Unified Data Repository
- PCF - Policy and Charging Function
- NSSF - Network Slice Selection Function
- BSF - Binding Support Function

The 5G SA core works in a different way to the 4G core - it uses a Service Based Architecture (SBI). Control plane functions are configured to register with the NRF, and the NRF then helps them discover the other core functions. Running through the other functions: The AMF handles connection and mobility management; a subset of what the 4G MME is tasked with. gNBs (5G basestations) connect to the AMF. The UDM, AUSF and UDR carry out similar operations as the 4G HSS, generating SIM authentication vectors and holding the subscriber profile. Session management is all handled by the SMF (previously the responsibility of the 4G MME/ SGWC/ PGWC). The NSSF provides a way to select the network slice. Finally there is the PCF, used for charging and enforcing subscriber policies.

The 5G SA core user plane is much simpler, as it only contains a single function. The UPF carries user data packets between the gNB and the external WAN. It connects back to the SMF too.

With the exception of the SMF and UPF, all config files for the 5G SA core functions only contain the function’s IP bind addresses/ local Interface names and the IP address/DNS name of the NRF.

## Tested Setup

Docker host machine

- Ubuntu 24.04 LTS

SDRs tested with srsLTE eNB

- Ettus USRP B210

UE

- Samsung Galaxy S21+ 5G LTE band 5

<h2 id="overview">Overview of Network Configuration</h2>

The figure describes the following setting example.
![image](https://user-images.githubusercontent.com/6804880/163012397-5707e107-2d4f-4c22-8fc3-dd20d4596f0d.png)

For reference, the Docker host VM on VMWare I have tried is as follows:
| CPU Cores | Memory | SSD | OS |
| --- | --- | --- | --- |
| 4 | 8GB | 50GB | Ubuntu 24.04 |

To connect UE from Docker host add the following route:

```
# ip route add 192.168.100.0/24 via 172.22.0.8
```

<h3 id="change_config">Changes in configuration files of docker_open5gs</h3>

**.env)**

| Item           | Value         |
| -------------- | ------------- |
| MCC            | 001           |
| MNC            | 01            |
| DOCKER_HOST_IP | 192.168.0.100 |

# USRP B210 Installation

Copy and paste these commands into your terminal. This will install UHD software as well as allow you to receive package updates.

```
sudo add-apt-repository ppa:ettusresearch/uhd
sudo apt-get update
sudo apt-get install libuhd-dev uhd-host
```

After installing, you need to download the FPGA images packages by running uhd images downloader on the command line (the actual path may differ based on your installation):

```
sudo /usr/lib/uhd/utils/uhd_images_downloader.py
```

Open the current user’s profile into a text editor

```
nano ~/.bash_profile
```

Add the export command for every environment variable you want to persist.

```
export UHD_IMAGES_DIR=/usr/share/uhd/images/
```

Save your changes.

Adding the environment variable to a user’s bash profile alone will not export it automatically. However, the variable will be exported the next time the user logs in to immediately apply all changes to bash_profile, use the source command.

```
source ~/.bash_profile
```

Next, update the system's shared library cache.

```
sudo ldconfig
```

Finally, make sure that the LD_LIBRARY_PATH environment variable is defined and includes the folder under which UHD was installed. Most commonly, you can add the line below to the end of your

```
$HOME/.bashrc file:
nano ~/.bash_profile
   export LD_LIBRARY_PATH=/usr/local/lib
```

## Configuring USB

On Linux, udev handles USB plug and unplug events. The following commands install a udev rule so that non-root users may access the device. This step is only necessary for devices that use USB to connect to the host computer, such as the B200, B210, and B200mini. This setting should take effect immediately and does not require a reboot or logout/login. Be sure that no USRP device is connected via USB when running these commands.

```
sudo cp /usr/lib/uhd/utils/uhd-usrp.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Connect the USRP

The installation of UHD and GNU Radio should now be complete. At this point, connect the USRP to the host computer.

```
uhd_find_devices

uhd_usrp_probe
```

# Build and Execution Instructions

- Mandatory requirements:
  - [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu)
  - [docker-compose](https://docs.docker.com/compose)

# Docker 25.0.5 Installation

```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
sudo usermod -aG docker $(whoami)
docker --version
```

# Docker Compose Installation

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

# Wireshark Installation

```
apt update
apt upgrade
apt install net-tools plocate traceroute git python3 python3-pip wireshark xterm -y
sudo usermod -aG wireshark $(whoami)
xauth add $(xauth -f ~root/.Xauthority list|tail -1)
```

## Open5GS

Clone repository and build base docker image of open5gs, kamailio, ueransim

```
# Build docker images for open5gs EPC/5GC components
git clone https://github.com/MAlexVR/docker_open5gs.git
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

# Build docker images for kamailio IMS components
cd ../ims_base
docker build --no-cache --force-rm -t docker_kamailio .

# Build docker images for srsRAN_4G eNB + srsUE (4G+5G)
cd ../srslte
docker build --no-cache --force-rm -t docker_srslte .
```

### Build and Run using docker-compose

```
cd ..
set -a
source .env
sudo ufw disable
sudo sysctl -w net.ipv4.ip_forward=1

# 4G Core Network + IMS + SMS over SGs
docker compose -f 4g-volte-deploy.yaml up -d

# srsLTE - eNB
docker-compose -f srsenb.yaml up -d

# Wowza Streaming Engine
docker-compose -f wowza.yaml build --no-cache
docker-compose -f wowza.yaml up -d

# Monitoring system: Grafana, Loki and Promtail
docker-compose -f monitor.yaml pull
docker-compose -f monitor.yaml up -d
```

## Configuration

For the quick run (eNB/gNB, CN in same docker network), edit only the following parameters in .env as per your setup

```
MCC
MNC
TEST_NETWORK --> Change this only if it clashes with the internal network at your home/office
DOCKER_HOST_IP --> This is the IP address of the host running your docker setup
SGWU_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if eNB is not running the same docker network/host
UPF_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if gNB is not running the same docker network/host
```

If eNB/gNB is NOT running in the same docker network/host as the host running the dockerized Core/IMS then follow the below additional steps

Under mme section in docker compose file (docker-compose.yaml, nsa-deploy.yaml), uncomment the following part

```
...
    # ports:
    #   - "36412:36412/sctp"
...
```

Under amf section in docker compose file (docker-compose.yaml, nsa-deploy.yaml, sa-deploy.yaml), uncomment the following part

```
...
    # ports:
    #   - "38412:38412/sctp"
...
```

If deploying in SA mode only (sa-deploy.yaml), then uncomment the following part under upf section

```
...
    # ports:
    #   - "2152:2152/udp"
...
```

If deploying in NSA mode only (nsa-deploy.yaml, docker-compose.yaml), then uncomment the following part under sgwu section

```
...
    # ports:
    #   - "2152:2152/udp"
...
```

For eNodeB, set static routing to eNodeB for packets going from eNodeB to the Docker host network (`172.22.0.0/24`).

```
# ip route add 172.22.0.0/24 via 192.168.0.130
```

## Register a UE information

Open (http://<DOCKER_HOST_IP>:9999) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials

```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber

## Connect the USRP

Try running "uhd_find_devices" and "uhd_usrp_probe".

## srsLTE eNB settings

If SGWU_ADVERTISE_IP is properly set to the host running the SGWU container in NSA deployment, then the following static route is not required.
On the eNB, make sure to have the static route to SGWU container (since internal IP of the SGWU container is advertised in S1AP messages and UE wont find the core in Uplink)

```
# NSA - 4G5G Hybrid deployment
ip r add <SGWU_CONTAINER_IP> via <SGWU_ADVERTISE_IP>
```

## Not supported

- IPv6 usage in Docker

## Portainer

Go to your favorite browser and open https://<ip_address>:9443

```
$ https://<ip_address>:9443
```

![image](https://github.com/user-attachments/assets/bd950544-b925-4494-ba4d-8f601495b6ea)
![image](https://github.com/user-attachments/assets/af8037a1-6ab4-4836-adda-299842844af7)

## Prepare the SIMCards

|   **VALUE**    |                                                  **SIM 1**                                                  |                                                  **SIM 2**                                                  |
| :------------: | :---------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------: |
|    **IMSI**    |                                               001010000010001                                               |                                               001010000010002                                               |
|   **MSISDN**   |                                                    10001                                                    |                                                    10002                                                    |
|    **MCC**     |                                                     001                                                     |                                                     001                                                     |
|    **MNC**     |                                                     01                                                      |                                                     01                                                      |
|    **ADM1**    |                                                  87025588                                                   |                                                  45314232                                                   |
|   **ICCID**    |                                             8988211000000543515                                             |                                             8988211000000543523                                             |
|     **Ki**     |                                      5BAD8598D1F631E3ED76F9333B8AA26F                                       |                                      DA4EDB6503743D404DA2F91A4446C26F                                       |
|    **OPc**     |                                      BA5205DDC6FCA1DF6B83A1CC69859514                                       |                                      1CFA68FDE88DCA322C1BF33D0F2709A0                                       |
|   **ICCID**    |                                             8988211000000543515                                             |                                             8988211000000543523                                             |
| **IMS DOMAIN** |                                      ims.mnc001.mcc001.3gppnetwork.org                                      |                                      ims.mnc001.mcc001.3gppnetwork.org                                      |
|    **IMPI**    |                              001010000010001@ims.mnc001.mcc001.3gppnetwork.org                              |                              001010000010002@ims.mnc001.mcc001.3gppnetwork.org                              |
|    **IMPU**    | sip:001010000010001@ims.mnc001.mcc001.3gppnetwork.org tel:10001 sip:10001@ims.mnc001.mcc001.3gppnetwork.org | sip:001010000010002@ims.mnc001.mcc001.3gppnetwork.org tel:10002 sip:10002@ims.mnc001.mcc001.3gppnetwork.org |
|   **PCSCF**    |                                   pcscf.ims.mnc001.mcc001.3gppnetwork.org                                   |                                   pcscf.ims.mnc001.mcc001.3gppnetwork.org                                   |
|    **KIC1**    |                                      CD9DB47453E5691B48971F86DFB408CE                                       |                                      056C8B738C1BCECA4F3A9C722E65562B                                       |
|    **KID1**    |                                      35132A622B39BFCCA25B84FE61C088BF                                       |                                      3F1D9A5FCEBB175644FDFDCBDE6B0E7C                                       |
|    **KIK1**    |                                      3381C956F30710A607061D5414F5F040                                       |                                      4054195F4984B8DA0ABF5B62393F0435                                       |

# ISIM Setup

Basically, you can learn how to use it in the sysmoUSIM manual or on the official homepage of pysim project. Let’s take a quickstart guide for this experiment.
Install dependencies:

```
$ sudo apt-get install pcscd pcsc-tools libccid libpcsclite-dev python3-pyscard -y
```

Connect SIM card reader to your computer and insert programmable SIM card to the reader.

Check the status of connection by entering the following command:

```
$ pcsc_scan
PC/SC device scanner
V 1.5.2 (c) 2001-2017, Ludovic Rousseau <ludovic.rousseau@free.fr>
Using reader plug'n play mechanism
Scanning present readers...
0: HID Global OMNIKEY 3x21 Smart Card Reader [OMNIKEY 3x21 Smart Card Reader] 00

Sun May 26 14:26:12 2019
 Reader 0: HID Global OMNIKEY 3x21 Smart Card Reader [OMNIKEY 3x21 Smart Card Re
  Card state: Card inserted,
  ATR: 3B 9F 96 80 1F C7 80 31 A0 73 BE 21 13 67 43 20 07 18 00 00 01 A5
...
```

Get the code of PySIM with installing dependency:

```
$ sudo apt-get install python3-pyscard python3-serial python3-pip
$ pip install pytlv
$ git clone git://git.osmocom.org/pysim
$ cd pysim
$ pip3 install -r requirements.txt
```

Read your SIM card:

```
$ ./pySim-read.py -p0
Using PC/SC reader (dev=0) interface
Reading ...
ICCID: 8988211000000213010
IMSI: 310789012345301
SMSP: ffffffffffffffffffffffffffffffffffffffffffffffffe1ffffffffffffffffffffffff
...
```

Program your SIM card:

```
python3 pySim-prog.py --pcsc-device=0 --type="sysmoISIM-SJA2" --name=Open5GS --pin-adm=87025588 --acc=0002 --iccid=8988211000000543515 --imsi=001010000010001 --mcc=001 --mnc=01 --ki=5BAD8598D1F631E3ED76F9333B8AA26F --opc=BA5205DDC6FCA1DF6B83A1CC69859514 --msisdn=10001 --ims-hdomain=ims.mnc001.mcc001.3gppnetwork.org --impi=001010000010001@ims.mnc001.mcc001.3gppnetwork.org --impu=sip:001010000010001@ims.mnc001.mcc001.3gppnetwork.org --pcscf=pcscf.ims.mnc001.mcc001.3gppnetwork.org
```

Unlock your SIM card:
Wrong KIC / KID / KIK bricks your SIM card.
Use MCC = 001, MNC = 01 for a test network, unless you know your MCC/MNC is supported by Android Carrier Privileges.
Refer to: https://github.com/herlesupreeth/CoIMS_Wiki/blob/master/README.md

```
$ git clone https://github.com/herlesupreeth/CoIMS_Wiki
$ cd CoIMS_Wiki
$ alias gp="java -jar $PWD/gp.jar"

$ gp --key-enc <KIC1> --key-mac <KID1> --key-dek <KIK1> -lvi
gp --key-enc A823883D5AD224BC52C28507AA1662B5 --key-mac 34A2175B766F22EF0531B5C4410AAD0F --key-dek 85729388DE30CB46934C99D3016787EA -lvi

$ gp --key-enc <KIC1> --key-mac <KID1> --key-dek <KIK1> --unlock
gp --key-enc A823883D5AD224BC52C28507AA1662B5 --key-mac 34A2175B766F22EF0531B5C4410AAD0F --key-dek 85729388DE30CB46934C99D3016787EA --unlock

gp --install applet.cap # sysmoISIM-SJA2 don't need this

gp -a 00A4040009A00000015141434C0000 -a 80E2900033F031E22FE11E4F06FFFFFFFFFFFFC114E46872F28B350B7E1F140DE535C2A8D5804F0BE3E30DD00101DB080000000000000001

gp -acr-list-aram
```

<h3 id="register_open5gs">Register subscribers information with Open5GS</h3>

### Provisioning of SIM information in open5gs HSS as follows:

Open (http://<DOCKER_HOST_IP>:9999) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```
![image](https://github.com/user-attachments/assets/af09b885-e343-4c81-8cb0-f6a0071bff17)
![image](https://github.com/user-attachments/assets/cf32780b-662a-44bc-ab95-ab9cb5957fde)
![image](https://github.com/user-attachments/assets/e52a31ef-6743-458d-8f51-10a3d32c45ad)

Please also register MSISDN. At that time, set the APN setting information as follows.
| APN | Type | QCI | ARP | Capability | Vulnerablility | MBR DL/UL(Kbps) | GBR DL/UL(Kbps) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| internet | IPv4 | 9 | 8 | Disabled | Disabled | unlimited/unlimited | |
| ims | IPv4 | 5 | 1 | Disabled | Disabled | 3850/1530 | |
| | | 1 | 2 | Enabled | Enabled | 128/128 | 128/128 |
| | | 2 | 4 | Enabled | Enabled | 812/812 | 812/812 |

See below for details.

`18. Install Open5GS in the same machine as Kamailio IMS - Install Open5GS from source`  
https://open5gs.org/open5gs/docs/tutorial/02-VoLTE-setup/

<h3 id="register_osmocom">Register the IMSI and MSISDN with OsmoHLR</h3>

Please login to the `osmohlr` container and register by referring to the following.

`6.1 Example: Add/Update/Delete Subscriber via VTY`  
https://downloads.osmocom.org/docs/latest/osmohlr-usermanual.pdf

The following is an example of registering subscriber information for IMSI=001010000001001 and MSISDN=1001.

First, login to the `osmohlr` container.

```
# docker exec -it osmohlr /bin/bash
```

Then telnet to localhost.

```
# telnet localhost 4258
...
OsmoHLR> enable
OsmoHLR#
```

Next, register the subscriber information for IMSI=001010000001001 and MSISDN=1001.

```
OsmoHLR# subscriber imsi 001010000010001 create
% Created subscriber 001010000010001
    ID: 1
    IMSI: 001010000010001
    MSISDN: none
OsmoHLR# subscriber imsi 001010000010001 update msisdn 10001
% Updated subscriber IMSI='001010000010001' to MSISDN='10001'
OsmoHLR#
```

Make sure this subscriber information is registered.

```
OsmoHLR# show subscribers all
ID     MSISDN        IMSI              IMEI              NAM
-----  ------------  ----------------  ----------------  -----
1      10001         001010000010001    -------------    CSPS
 Subscribers Shown: 1
OsmoHLR#
```

This setting is required to function as **SMS over SGs**.
![image](https://github.com/user-attachments/assets/9cd6a1d7-241a-4970-aef9-9573c8327de1)


<h3 id="try">Try VoLTE and SMS</h3>

Make sure that you can make a VoLTE call and SMS to the MSISDN. If your device does not support **SMS over IMS**, you can send SMS with **SMS over SGs** depending on your device.

**Note. Kamailio's SMS (SMS over IMS) seems to have a bug in handling multibyte messages, which causes garbled characters in SMS.
On the other hand, OsmoMSC (SMS over SGs) seems to handle multibyte messages properly without garbled characters.**

<h4 id="osmomsc_send_command">Send SMS from OsmoMSC VTY terminal (SMS over SGs)</h4>

You can send SMS to the destination terminal by command operation on the OsmoMSC VTY terminal (SMS over SGs).
Please login to the `osmomsc` container and send SMS from the command line as following.

`14 Configuring the Core Network`  
`11.3.3 The list command`  
https://downloads.osmocom.org/docs/latest/osmomsc-usermanual.pdf

**For example, if the following IMSI and MSISDN are registered in OsmoHLR)**
| IMSI | MSISDN | SIM |
| --- | --- | --- |
| 001010000010000 | 10000 | x |
| 001010000010001 | 10001 | o |
| 001010000010002 | 10002 | o |

First, login to the `osmomsc` container.

```
# docker exec -it osmomsc /bin/bash
```

Then telnet to localhost.

```
# telnet localhost 4254
...
OsmoMSC> enable
OsmoMSC#
```

- Command line to send SMS from MSISDN=10001 to MSISDN=10002 where the corresponding SIM exists

```
OsmoMSC# subscriber msisdn 10002 sms sender msisdn 10001 send TEST MESSAGE
```

- Command line to send SMS from MSISDN=10000 to MSISDN=10002 for which there is no corresponding SIM

```
OsmoMSC# subscriber msisdn 10002 sms sender msisdn 10000 send TEST MESSAGE
```

### Provisioning of SIM information in pyHSS is as follows:

1. Goto http://<DOCKER_HOST_IP>:8080/docs/
![image](https://github.com/user-attachments/assets/170ef7f6-cfbc-4da8-afce-fea04418829e)
   
3. Select **apn** -> **Create new APN** -> Press on **Try it out**. Then, in payload section use the below JSON and then press **Execute**
![image](https://github.com/user-attachments/assets/86bbd317-52db-452b-9b4e-35eb223607d7)

```
{
  "apn": "internet",
  "arp_priority": 0,
  "nidd_mechanism": 0,
  "ip_version": 0,
  "arp_preemption_capability": true,
  "nidd_rds": 0,
  "pgw_address": "string",
  "arp_preemption_vulnerability": true,
  "nidd_preferred_data_mode": 0,
  "sgw_address": "string",
  "charging_rule_list": "string",
  "last_modified": "2024-08-19T20:42:13Z",
  "charging_characteristics": "stri",
  "nbiot": true,
  "apn_ambr_dl": 0,
  "nidd_scef_id": "string",
  "apn_id": 1,
  "apn_ambr_ul": 0,
  "nidd_scef_realm": "string",
  "qci": 0
}
```

Take note of **apn_id** specified in **Response body** under **Server response** for **internet** APN

Repeat creation step for following payload

```
{
  "apn": "ims",
  "arp_priority": 0,
  "nidd_mechanism": 0,
  "ip_version": 0,
  "arp_preemption_capability": true,
  "nidd_rds": 0,
  "pgw_address": "string",
  "arp_preemption_vulnerability": true,
  "nidd_preferred_data_mode": 0,
  "sgw_address": "string",
  "charging_rule_list": "string",
  "last_modified": "2024-08-19T20:44:06Z",
  "charging_characteristics": "stri",
  "nbiot": true,
  "apn_ambr_dl": 0,
  "nidd_scef_id": "string",
  "apn_id": 2,
  "apn_ambr_ul": 0,
  "nidd_scef_realm": "string",
  "qci": 0
}
```

Take note of **apn_id** specified in **Response body** under **Server response** for **ims** APN

**Execute this step of APN creation only once**

3. Next, select **auc** -> **Create new AUC** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in ki, opc and amf for your SIM and then press **Execute**
![image](https://github.com/user-attachments/assets/dc8f059d-8fcd-4b49-8a8e-01d28848b8e0)

```
{
  "sqn": 0,
  "pin1": "string",
  "misc1": "string",
  "iccid": "8988211000000543515",
  "pin2": "string",
  "misc2": "string",
  "imsi": "001010000010001",
  "puk1": "string",
  "misc3": "string",
  "batch_name": "string",
  "puk2": "string",
  "misc4": "string",
  "auc_id": 1,
  "sim_vendor": "string",
  "kid": "string",
  "last_modified": "2024-08-19T20:46:55Z",
  "ki": "5BAD8598D1F631E3ED76F9333B8AA26F",
  "esim": true,
  "psk": "string",
  "opc": "BA5205DDC6FCA1DF6B83A1CC69859514",
  "lpa": "string",
  "des": "string",
  "amf": "8000",
  "adm1": "87025588"
}
```
```
{
  "sqn": 0,
  "pin1": "string",
  "misc1": "string",
  "iccid": "8988211000000543523",
  "pin2": "string",
  "misc2": "string",
  "imsi": "001010000010002",
  "puk1": "string",
  "misc3": "string",
  "batch_name": "string",
  "puk2": "string",
  "misc4": "string",
  "auc_id": 2,
  "sim_vendor": "string",
  "kid": "string",
  "last_modified": "2024-08-19T20:49:09Z",
  "ki": "DA4EDB6503743D404DA2F91A4446C26F",
  "esim": true,
  "psk": "string",
  "opc": "1CFA68FDE88DCA322C1BF33D0F2709A0",
  "lpa": "string",
  "des": "string",
  "amf": "8000",
  "adm1": "45314232"
}
```

Take note of **auc_id** specified in **Response body** under **Server response**

**Replace imsi, ki, opc and amf as per your programmed SIM**

4. Next, select **subscriber** -> **Create new SUBSCRIBER** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in imsi, auc_id and apn_list for your SIM and then press **Execute**
![image](https://github.com/user-attachments/assets/c47af15d-8a49-430e-a819-0cfa2607792c)

```
{
  "enabled": true,
  "roaming_enabled": true,
  "last_modified": "2024-08-19T21:02:45Z",
  "auc_id": 1,
  "roaming_rule_list": null,
  "default_apn": 1,
  "subscribed_rau_tau_timer": 300,
  "apn_list": "1,2",
  "serving_mme": null,
  "msisdn": "10001",
  "serving_mme_timestamp": null,
  "subscriber_id": 1,
  "ue_ambr_dl": 0,
  "serving_mme_realm": null,
  "imsi": "001010000010001",
  "ue_ambr_ul": 0,
  "serving_mme_peer": null,
  "nam": 0
}
```
```
{
  "enabled": true,
  "roaming_enabled": true,
  "last_modified": "2024-08-19T21:08:29Z",
  "auc_id": 2,
  "roaming_rule_list": null,
  "default_apn": 1,
  "subscribed_rau_tau_timer": 300,
  "apn_list": "1,2",
  "serving_mme": null,
  "msisdn": "10002",
  "serving_mme_timestamp": null,
  "subscriber_id": 2,
  "ue_ambr_dl": 0,
  "serving_mme_realm": null,
  "imsi": "001010000010002",
  "ue_ambr_ul": 0,
  "serving_mme_peer": null,
  "nam": 0
}
```

- **auc_id** is the ID of the **AUC** created in the previous steps
- **default_apn** is the ID of the **internet** APN created in the previous steps
- **apn_list** is the comma separated list of APN IDs allowed for the UE i.e. APN ID for **internet** and **ims** APN created in the previous steps

**Replace imsi and msisdn as per your programmed SIM**

5. Finally, select **ims_subscriber** -> **Create new IMS SUBSCRIBER** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in imsi, msisdn, msisdn_list, scscf_peer, scscf_realm and scscf for your SIM/deployment and then press **Execute**
![image](https://github.com/user-attachments/assets/bc035d28-3b5a-4047-a0d6-ff3fe2e1d8c2)

```
{
  "pcscf": null,
  "scscf": "sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060",
  "pcscf_realm": null,
  "scscf_timestamp": "2024-08-15T20:47:28Z",
  "pcscf_active_session": null,
  "scscf_realm": "ims.mnc001.mcc001.3gppnetwork.org",
  "ims_subscriber_id": 1,
  "pcscf_timestamp": null,
  "scscf_peer": "scscf.ims.mnc001.mcc001.3gppnetwork.org;hss.ims.mnc001.mcc001.3gppnetwork.org",
  "msisdn": "10001",
  "pcscf_peer": null,
  "sh_template_path": null,
  "msisdn_list": "[10001]",
  "xcap_profile": null,
  "last_modified": "2024-08-19T21:14:31Z",
  "imsi": "001010000010001",
  "sh_profile": "string",
  "ifc_path": "default_ifc.xml"
}
```
```
{
  "pcscf": null,
  "scscf": "sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060",
  "pcscf_realm": null,
  "scscf_timestamp": "2024-08-15T20:43:53Z",
  "pcscf_active_session": null,
  "scscf_realm": "ims.mnc001.mcc001.3gppnetwork.org",
  "ims_subscriber_id": 2,
  "pcscf_timestamp": null,
  "scscf_peer": "scscf.ims.mnc001.mcc001.3gppnetwork.org;hss.ims.mnc001.mcc001.3gppnetwork.org",
  "msisdn": "10002",
  "pcscf_peer": null,
  "sh_template_path": null,
  "msisdn_list": "[10002]",
  "xcap_profile": null,
  "last_modified": "2024-08-19T21:15:22Z",
  "imsi": "001010000010002",
  "sh_profile": "string",
  "ifc_path": "default_ifc.xml"
}
```

**Replace imsi, msisdn and msisdn_list as per your programmed SIM**

**Replace scscf_peer, scscf and scscf_realm as per your deployment**

## Not supported

- IPv6 usage in Docker

## Wowza Streaming Engine

Go to your favorite browser and open http://<ip_address>:8088, User: admin - Password: admin

```
$ http://<ip_address>:8088
```

![image](https://user-images.githubusercontent.com/6804880/162839701-e59437e1-b888-42a0-9edc-629c9e8b7a3b.png)

## Grafana

Go to your favorite browser and open http://<ip_address>:3010, User: admin - Password: admin

```
$ http://<ip_address>:3010
```

![image](https://user-images.githubusercontent.com/6804880/163682654-5cb27c37-22a2-493c-ab60-32a680fb6684.png)

Add the Loki datasource with http://loki:3100
![image](https://user-images.githubusercontent.com/6804880/163682735-80b10d96-cd52-4d68-bb6e-341c345a41a8.png)

Explore Open5GS logs
![image](https://user-images.githubusercontent.com/6804880/163682753-25259708-b528-47d9-bf32-c98f43f61af6.png)

![image](https://user-images.githubusercontent.com/6804880/163682773-40d5d9df-76e9-46e8-825c-0b9b47ae3f76.png)

---

[docker_open5gs](https://github.com/herlesupreeth/docker_open5gs) is a excellent software to try **VoLTE** and **SMS** easily. I would like to thank all the software developers and contributors related especially to Herle Supreeth and Shigeru Ishida.
