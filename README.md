# mysql-gelf
A (very) basic Bash script to send MySQL status information to GrayLog through GELF

## Introduction

[GrayLog](https://www.graylog.org/) is becoming a great tool for logs aggregation. It offers a good subset of the functionality you would use [Splunk](http://www.splunk.com/) for but for free (money-wise).

This bash script aims to provide a data source for MySQL, a mechanism for feeding MySQL status information into GrayLog. The script aims to be as simple as possible and requires only bash and some basic commands that should hopefully be installed in any server. Information is transmitted using the [GELF](https://www.graylog.org/resources/gelf-2/) format. The script is triggered by cron. The information to be fed is retrieved through MySQL's `SHOW GLOBAL STATUS` query.

## Installation

The installation is compromised of the following steps,

1. Set up and configuring the script.
2. Launch a new input in GrayLog.
3. Set up a cron job to run the script periodically.

### Script set-up

The script needs only to reside on the file system of a machine that has both 1) Access to the MySQL instance to be monitored and 2) The possibility of setting up a cron job on it. You can just copy the script to the server or simply clone the Git repository.

Please edit the `mysql-status.sh` and replace the variables with your MySQL credentials and the location of the GrayLog instance you will going to be reporting to.

There are 2 other files that allow configuring the parameters that are going to be fed into GrayLog: `variables-abs` and `variables-diff`. A complete reference of the parameters is available in the [MySQL manual](https://dev.mysql.com/doc/refman/5.1/en/server-status-variables.html).

`variables-abs`: List of variables to report whose value is absolute, doesn't depend on time span.
`variables-diff`: List of variables to report whose value is relative, depends on the difference between the current value and the last recorded one.

### GrayLog's Input

An input has to be set up in GrayLog in order to consume the messages the scrip is going to send. Go to GrayLog > System > Inputs and launch a new **GELF UDP** input on port **12305**

### Cron Job

The last step is to create a cron job that will trigger the script every so often. Depends on the level of granularity you are trying to achieve, you can decide how often to trigger the script. Most users will probably do it every minute.

`crontab -e`

`* * * * * /path/to/mysql-gelf/mysql-status.sh`

## Limitations

* Doesn't support messages [chunking](https://www.graylog.org/resources/gelf-2/).
This imposes a limit of 8192 bytes on each message. In case you are looking into monitoring many parameters, this can be problematic. We use messages compression to allow for more information in a message but you can easily reach the ceiling when adding more parameters to monitor.

* The smallest granularity that can be achieved with the script is 1 minute. The script is triggered by the cron mechanism, which offers a granularity of no less than 1 minute.

## Backlog

1. Make a cleaner separation of script configuration and script behaviour.
2. Add validation and error handling.
3. Allow messages chunking.

## How to Contribute

This is a very basic script. It can become a much better tool if we all add our enhancements into it. Please feel free to fork the repo and send pull requests to any enhancements you have had the chance to write. Thank you.
