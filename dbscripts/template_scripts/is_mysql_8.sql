--
-- Copyright 2025 WSO2 LLC. (http://wso2.com)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

DROP DATABASE IF EXISTS WSO2SHARED_DB;
DROP DATABASE IF EXISTS WSO2IDENTITY_DB;
DROP DATABASE IF EXISTS WSO2AGENTIDENTITY_DB;
DROP DATABASE IF EXISTS WSO2IS_BPS_DB;
DROP DATABASE IF EXISTS WSO2CONSENT_DB;
DROP DATABASE IF EXISTS WSO2_METRICS_DB;
DROP DATABASE IF EXISTS WSO2_CLUSTER_DB;
DROP DATABASE IF EXISTS IS_ANALYTICS_DB;
DROP DATABASE IF EXISTS WSO2_CARBON_DB;
DROP DATABASE IF EXISTS WSO2_PERSISTENCE_DB;
DROP DATABASE IF EXISTS WSO2_STATUS_DASHBOARD_DB;

CREATE DATABASE WSO2SHARED_DB character set latin1;
CREATE DATABASE WSO2IDENTITY_DB character set latin1;
CREATE DATABASE WSO2IS_BPS_DB character set latin1;
CREATE DATABASE WSO2AGENTIDENTITY_DB character set latin1;
CREATE DATABASE WSO2CONSENT_DB character set latin1;
CREATE DATABASE WSO2_METRICS_DB character set latin1;
CREATE DATABASE WSO2_CLUSTER_DB character set latin1;
CREATE DATABASE IS_ANALYTICS_DB character set latin1;
CREATE DATABASE WSO2_CARBON_DB character set latin1;
CREATE DATABASE WSO2_PERSISTENCE_DB character set latin1;
CREATE DATABASE WSO2_STATUS_DASHBOARD_DB character set latin1;
