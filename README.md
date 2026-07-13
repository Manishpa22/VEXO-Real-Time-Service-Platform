# VEXO - Real-Time On-Demand Service Platform

VEXO is a production-ready, dual-interface service platform built to solve real-world logistical routing and distributed system challenges. It decouples the customer experience from aggressive background tracking using a containerized Node.js backend.

## 🚀 Architectural Highlights (Flipkart GRiD 8.0 Focus)
* **Real-Time Geospatial Tracking:** Implemented AWS API Gateway WebSockets to maintain persistent connections, streaming live GPS coordinates from the Partner App to the Customer App with sub-second latency.
* **Decoupled Client Architecture:** Separated the ecosystem into two distinct Flutter applications (Customer & Partner) to optimize battery consumption, background location services, and security constraints.
* **High-Availability Infrastructure:** The Node.js backend is fully containerized using Docker, ready for orchestration and horizontal scaling during high-traffic bursts.
* **Enterprise Authentication:** Eliminated vendor lock-in by designing a custom DLT-compliant OTP service using the MSG91 SMS gateway and securing sessions with JSON Web Tokens (JWT).
* **Cost-Optimized Database:** Configured Amazon DynamoDB with custom Time-To-Live (TTL) policies for automatic state cleanup and efficient data retention.

## 💻 Tech Stack
* **Frontend:** Flutter, Dart
* **Backend:** Node.js, Express.js
* **Cloud & Infrastructure:** AWS (API Gateway), Docker
* **Database:** Amazon DynamoDB, Hive (Local caching)
* **Third-Party Integrations:** MSG91, Google Maps SDK, Firebase Cloud Messaging (FCM)
