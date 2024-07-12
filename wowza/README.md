# Wowza Streaming Engine Unofficial docker image
Inspired by [sameersbn/docker-wowza](https://github.com/sameersbn/docker-wowza) and [Official WSE image](https://hub.docker.com/r/wowzamedia/wowza-streaming-engine-linux).

## Environment Variables

**`WSE_LIC`**

Your Wowza Streaming Engine license key

**`DIRECT_START`**

If any value has been set, Wowza Streaming Engine would be started directly, not with supervisor. This could be useful for developers to see console logs at once like when you have started `startup.sh` script.