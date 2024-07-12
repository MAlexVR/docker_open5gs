#!/bin/bash
if ! [[ "$(ls -A /usr/local/WowzaStreamingEngine/conf)" ]]
then
    echo "Wowza Streaming Engine configuration not found. Restoring."
    cp -r /root/wowza-backup/conf/* /usr/local/WowzaStreamingEngine/conf
fi

if [ -z $WSE_LIC ]
then
    echo "Please set WSE_LIC"
    exit 1
else
    echo $WSE_LIC > /usr/local/WowzaStreamingEngine/conf/Server.license
    cp /root/hosts /etc/
    cp /root/wms-server.jar /usr/local/WowzaStreamingEngine-4.8.23+2/lib/
    cp /root/wms-server.jar /usr/local/WowzaStreamingEngine-4.8.23+2/manager/temp/webapps/enginemanager/WEB-INF/lib/
    cp /root/updateavailable_tag.class /usr/local/WowzaStreamingEngine-4.8.23+2/manager/temp/webapps/enginemanager/WEB-INF/tags/wmsform/
    cp /root/updateavailablejava_tag.class /usr/local/WowzaStreamingEngine-4.8.23+2/manager/temp/webapps/enginemanager/WEB-INF/tags/wmsform/
    /etc/init.d/WowzaStreamingEngine restart 
    /etc/init.d/WowzaStreamingEngineManager restart
fi

if [ -z $DIRECT_START ]
then
    exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
else
    /usr/local/WowzaStreamingEngine/manager/bin/startmgr.sh > mngr.log 2>&1 &
    /usr/local/WowzaStreamingEngine/bin/startup.sh
fi
