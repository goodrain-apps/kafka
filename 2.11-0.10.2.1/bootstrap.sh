#!/bin/bash

if [[ x$DEBUG != x ]]; then
  set -x
fi

# Set java vm start options
case ${MEMORY_SIZE} in
    "micro")
       export default_java_mem_opts="-Xms90m -Xmx90m -Xss512k  -XX:MaxDirectMemorySize=12M"
       echo "Optimizing java process for 128M Memory...." >&2
       ;;
    "small")
       export default_java_mem_opts="-Xms180m -Xmx180m -Xss512k -XX:MaxDirectMemorySize=24M "
       echo "Optimizing java process for 256M Memory...." >&2
       ;;
    "medium")
       export default_java_mem_opts="-Xms360m -Xmx360m -Xss512k -XX:MaxDirectMemorySize=48M"
       echo "Optimizing java process for 512M Memory...." >&2
       ;;
    "large")
       export default_java_mem_opts="-Xms720m -Xmx720m -Xss512k -XX:MaxDirectMemorySize=96M "
       echo "Optimizing java process for 1G Memory...." >&2
       ;;
    "2xlarge")
       export default_java_mem_opts="-Xms1420m -Xmx1420m -Xss512k -XX:MaxDirectMemorySize=192M"
       echo "Optimizing java process for 2G Memory...." >&2
       ;;
    "4xlarge")
       export default_java_mem_opts="-Xms2840m -Xmx2840m -Xss512k -XX:MaxDirectMemorySize=384M "
       echo "Optimizing java process for 4G Memory...." >&2
       ;;
    "8xlarge")
       export default_java_mem_opts="-Xms5680m -Xmx5680m -Xss512k -XX:MaxDirectMemorySize=768M"
       echo "Optimizing java process for 8G Memory...." >&2
       ;;
    16xlarge|32xlarge|64xlarge)
       export default_java_mem_opts="-Xms8G -Xmx8G -Xss512k -XX:MaxDirectMemorySize=1536M"
       echo "Optimizing java process for biger Memory...." >&2
       ;;
    *)
       export default_java_mem_opts="-Xms128m -Xmx128m -Xss512k -XX:MaxDirectMemorySize=24M"
       echo "Optimizing java process for 256M Memory...." >&2
       ;;
esac

if [[ x${KAFKA_HEAP_OPTS} == x ]]; then
  export KAFKA_HEAP_OPTS="-Dlogging.level=$LOGGING_LEVEL -Dfile.encoding=$FILE_ENCODING"
else
  export KAFKA_HEAP_OPTS="${default_java_opts} ${KAFKA_HEAP_OPTS} -Dlogging.level=$LOGGING_LEVEL -Dfile.encoding=$FILE_ENCODING"
fi

index=1
while [[ `net portcheck $ZOOKEEPER_HOST $ZOOKEEPER_PORT` != 'open' ]]; do
	((index++ > 30)) && {
		echo "wait zookeeper timeout."
		exit 11
	}
	echo "wait zookeeper start."
	sleep 2
done
echo "zookeeper is started."

# Launch
exec kafka-server-start.sh /opt/kafka/config/server.properties \
--override broker.id=${HOSTNAME##*-} \
--override zookeeper.connect=$ZOOKEEPER_HOST:$ZOOKEEPER_PORT \
--override log.dir=$LOG_DIR \
--override listeners=$LISTENERS \
--override auto.create.topics.enable=$AUTO_CREATE_TOPICS_ENABLE \
--override auto.leader.rebalance.enable=$AUTO_LEADER_REBALANCE_ENABLE \
--override background.threads=$BACKGROUND_THREADS \
--override compression.type=$COMPRESSION_TYPE \
--override delete.topic.enable=$DELETE_TOPIC_ENABLE \
--override leader.imbalance.check.interval.seconds=$LEADER_IMBALANCE_CHECK_INTERVAL_SECONDS \
--override leader.imbalance.per.broker.percentage=$LEADER_IMBALANCE_PER_BROKER_PERCENTAGE \
--override log.flush.interval.messages=$LOG_FLUSH_INTERVAL_MESSAGES \
--override log.flush.offset.checkpoint.interval.ms=$LOG_FLUSH_OFFSET_CHECKPOINT_INTERVAL_MS \
--override log.flush.scheduler.interval.ms=$LOG_FLUSH_SCHEDULER_INTERVAL_MS \
--override log.retention.bytes=$LOG_RETENTION_BYTES \
--override log.retention.hours=$LOG_RETENTION_HOURS \
--override log.roll.hours=$LOG_ROLL_HOURS \
--override log.roll.jitter.hours=$LOG_ROLL_JITTER_HOURS \
--override log.segment.bytes=$LOG_SEGMENT_BYTES \
--override log.segment.delete.delay.ms=$LOG_SEGMENT_DELETE_DELAY_MS \
--override message.max.bytes=$MESSAGE_MAX_BYTES \
--override min.insync.replicas=$MIN_INSYNC_REPLICAS \
--override num.io.threads=$NUM_IO_THREADS \
--override num.network.threads=$NUM_NETWORK_THREADS \
--override num.recovery.threads.per.data.dir=$NUM_RECOVERY_THREADS_PER_DATA_DIR \
--override num.replica.fetchers=$NUM_REPLICA_FETCHERS
