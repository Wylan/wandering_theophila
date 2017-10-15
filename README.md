# wandering_theophila
A simple docker application to watch sites for changes. Change notifications will be sent via pushover.

# Usage
The container requires the following environment variables:

* `USER_KEY` Pushover user key.
* `API_TOKEN` Pushover application API token.
* `MEMCACHED_HOST` hostname for memcache.
* `MEMCACHED_PORT` optional port for memcache defaults to 11211.
* `URLS` comma separated list of urls to watch.

Schedule the container to run periodically using cron, AWS Cloudwatch, Docker Swarm, etc. Be nice to the sites you're monitoring, once an hour is probably a good interval.
