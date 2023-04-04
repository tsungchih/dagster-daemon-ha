# Enabling High Availability For Dagster Daemon Using Leader Elector In Kubernetes

Dagster, in the modern data stack, is a cloud-native data orchestrator for the whole development lifecycle. Dagster is gaining more and more popularity due to its several stunning features, such as Software Defined Assets, integrated data lineage, data catalog and observability, and declarative programming model, etc. Dagster Daemon, in the Dagster deployment architecture, is one of critical components for handling schedulers, sensors, and run queueing.

However, the Dagster Daemon does not support replicas which probably be the single point of failure (SPOF) for the holistic data solution relying on Dagster.

Our deployment of Dagster in a autoscaling enabled GKE cluster, we did see that a large number of Dagster jobs were all queued when Dagster Daemon had went down due to scale-down behavior of GKE cluster. The queued Dagster jobs started to be launched after Dagster Daemon has been rescheduled and run in another GKE node. Several side effects come in:
- A burst of resource consumption when Dagster Daemon comes back. This could be overcame by setting `max_concurrent_runs` in the `QueuedRunCoordinator` to limit the maximum number of runs that are allowed to be in progress at once.
- Introduce further latency of data transformation. Draw additional data transformation latency waiting in the queue.

This project includes the source for my article [A Workaround Solution To Enabling High Availability For Dagster Daemon Based On Leader Election In Kubernetes](https://medium.com/@georgelai/a-workaround-solution-to-enabling-high-availability-for-dagster-daemon-ea7af86c1366).

The folder `leader-elector` is cloned from GitHub repository [instana/leader-elector](https://github.com/instana/leader-elector).

The behavior of the workaround solution works as expected to guarantee only one Dagster Daemon is running given any of time. Nonetheless, we can see the Dagster Daemon was complaining that there have multiple daemon processes running. And we don’t see the similar error after running for a while. We need to investigate if this introduces any side effect.
