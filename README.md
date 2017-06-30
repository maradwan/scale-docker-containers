# Scale Docker Containers by using HAproxy.

Tested on Shiny https://shiny.rstudio.com/

## Requirements

* [docker]
* [docker-compose]


### auto_docker.sh is checking session and running scale_docker script
Use Cron for running auto_docker.sh script. 
*/5 * * * * auto_docker.sh

### scale_docker.sh is a Service discovery and autoscaling 
