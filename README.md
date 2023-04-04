# Enabling High Availability For Dagster Daemon Using Leader Elector In Kubernetes

Dagster, in the modern data stack, is a cloud-native data orchestrator for the whole development lifecycle. Dagster is gaining more and more popularity due to its several stunning features, such as Software Defined Assets, integrated data lineage, data catalog and observability, and declarative programming model, etc. Dagster Daemon, in the Dagster deployment architecture, is one of critical components for handling schedulers, sensors, and run queueing.

However, the Dagster Daemon does not support replicas which probably be the single point of failure (SPOF) for the holistic data solution relying on Dagster.

Our deployment of Dagster in a autoscaling enabled GKE cluster, we did see that a large number of Dagster jobs were all queued when Dagster Daemon had went down due to scale-down behavior of GKE cluster. The queued Dagster jobs started to be launched after Dagster Daemon has been rescheduled and run in another GKE node. Several side effects come in:
- Resource consumption storm when Dagster Daemon comes back. (could be overcame by setting `max_concurrent_runs` in the `QueuedRunCoordinator` to limit the maximum number of runs that are allowed to be in progress at once)
- Introduce further latency of data transformation. Draw additional data transformation latency waiting in the queue.

This project is the source for my article [Enabling High Availability For Dagster Daemon Using Leader Elector In Kubernetes](https://medium.com).

The folder `leader-elector` is cloned from GitHub repository [instana/leader-elector](https://github.com/instana/leader-elector).

