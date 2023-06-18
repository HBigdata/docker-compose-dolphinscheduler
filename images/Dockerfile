FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos-jdk:7.7.1908


ADD apache-dolphinscheduler-3.1.7-bin.tar.gz /opt/apache

# 添加 DolphinScheduler 包
ENV DolphinScheduler_VERSION 3.1.7
ADD apache-dolphinscheduler-${DolphinScheduler_VERSION}-bin.tar.gz /opt/apache/
ENV DolphinScheduler_HOME /opt/apache/dolphinscheduler
RUN ln -s /opt/apache/apache-dolphinscheduler-${DolphinScheduler_VERSION}-bin $DolphinScheduler_HOME

# 添加MySQL 驱动
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/tools/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/master-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/worker-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/alert-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/api-server/libs/

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh

RUN chown -R hadoop:hadoop /opt/apache

WORKDIR /opt/apache
