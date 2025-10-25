# Azure Container Apps Album API - MVP Project

This project demonstrates a complete Infrastructure as Code (IaC) implementation for deploying a .NET web API to Azure Container Apps. It's based on the [Azure Container Apps code-to-cloud quickstart](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote) with enhanced enterprise-grade infrastructure automation.


Project requiremnets:
1.	Build an MVP pipeline to manage Infrastructure as Code components
2.  Include versioning on your pipeline
3.  Include Breaking change detection and testing of your infrastructure components.



## 🏗️ Project Overview

This repository contains:
1. **Backend Web API** - backend web API service that returns a static collection of music albums
2. **Infrastructure as Code** - Complete Azure infrastructure automation using Bicep including ACR and ACA
3. **CI/CD Pipelines** - Azure DevOps pipelines for automated deployment with versioning
4. **Multi-environment and region Support** - DEV, TST*, and PRD* environment configurations and EUS, WEU regions support

## 🖥️ Backend Web API

### Technology Stack
- **.NET 6.0** - C# web API framework *old version (not 9.0) 1)tutorial .NET 2) check dependabot
- **ASP.NET Core** - Web framework for building HTTP services
- **Docker** - Containerization for consistent deployments
- **Azure Container Apps** - Serverless container hosting platform
- **GitHub** - Git repository
- **dependabot** - Monitor vulnerabilities in dependencies used in your project and keep your dependencies up-to-date

## 🏗️ Infrastructure as Code (IaC)

### Azure Resources

#### 🔒 **Azure Container Registry (ACR)**
- **Purpose**: Private Docker container registry for storing application images
- **Features**:
  - Admin user enabled for simplified authentication #todo use assigned idenitity
  - Geo-replication support for production workloads
  - Integration with Azure Container Apps for seamless deployments

#### 📦 **Azure Container Apps (ACA)**
- **Purpose**: Serverless container hosting platform with built-in scaling
- **Configuration**:
  - **Managed Environment**: Isolated network boundary for container apps
  - **External Ingress**: HTTPS endpoint with automatic SSL certificates
  - **Auto-scaling**: HTTP-based scaling from 2 to 10 replicas
  - **Resource Allocation**: 1 vCPU and 2GB memory per container

#### 📊 **Log Analytics Workspace**
- **Purpose**: Centralized logging and monitoring for Container Apps
- **Configuration**:
  - **Retention**: 30 days for cost optimization
  - **Integration**: Automatic log forwarding from Container Apps environment

#### 🌐 **Container Apps Environment**
- **Purpose**: Shared boundary for related container apps
- **Features**:
  - **Log Analytics Integration**: Automatic log collection and forwarding
  - **Network Isolation**: Secure communication between container apps
  - **Shared Resources**: Optimized resource utilization across apps

### Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Subscription                       │
├─────────────────────────────────────────────────────────────┤
│  Resource Group: rg-album-containerapps-{ENV}              │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │  Azure Container │  │  Log Analytics  │                 │
│  │   Registry (ACR) │  │   Workspace     │                 │
│  │                 │  │                 │                 │
│  │ • Store Images  │  │ • Collect Logs  │                 │
│  │ • Version Tags  │  │ • Monitoring    │                 │
│  └─────────────────┘  └─────────────────┘                 │
│           │                       │                        │
│           │            ┌─────────────────┐                │
│           └──────────▶ │ Container Apps  │                │
│                        │   Environment   │                │
│                        │                 │                │
│                        │ ┌─────────────┐ │                │
│                        │ │ Album API   │ │                │
│                        │ │ Container   │ │                │
│                        │ │             │ │                │
│                        │ │ • HTTPS     │ │                │
│                        │ │ • Auto Scale│ │                │
│                        │ │ • Health*   │ │                │
│                        │ └─────────────┘ │                │
│                        └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 CI/CD Pipeline Architecture

### Pipeline Components

#### 📋 **Build Job**
- **build-app.yaml**: .NET application build and testing
  - NuGet package restoration
  - Application compilation with Release configuration
  - Unit test execution with code coverage
  - Test results publishing

#### 🏗️ **Infrastructure Job**
- **build-basic-infra.yaml**: Azure Container Registry deployment
  - Create on-fly param file by using functions create_header and create_env_config 
  - ACR resource provisioning

#### 📦 **Image Build Job**
- **build-images.yaml**: Docker image creation and publishing
  - Docker image building from Dockerfile
  - Image tagging with build ID and version from vars-global.yaml
  - Push to Azure Container Registry

#### 🚀 **Deployment Job**
- **build-aca.yaml**: Container Apps deployment
  - Create on-fly param file by using functions create_header, create_env_config and create_aca_config
  - Bicep template deployment for Container Apps

#### ✅ **Testing Job**
- **test-deployment.yaml**: Post-deployment validation
  - Container Apps health verification (running state)
  - Endpoint testing and validation (curl)
  - Displays the most recent 20 log entries 

#### 📝 **Documentation Job**
- **create-wiki-page.sh**: Automated documentation generation
  - Container Apps revision details
  - Wiki page creation with markdown formatting (name, state, creation time, traffic weight)
  - Push into Git Wiki in Azure DevOps

### Environment Configuration

#### 🔧 **Multi-Environment Support**
- DEV
- TST*
- PRD*

#### 🌍 **Multi-Region Support**
- **East US (eus)**: Primary deployment region
- **West Europe (weu)**: Secondary region

## 📁 Project Structure

```
containerapps-MVP/
├── src/                          # Source code
│   ├── albumapi_csharp.csproj    # .NET project file
│   ├── Program.cs                # Application entry point
│   ├── Dockerfile                # Container configuration
│   └── Properties/               # Application settings
├── iac/                          # Infrastructure as Code
│   ├── infrastructure/           # Bicep templates
│   │   ├── aca.bicep            # Container Apps infrastructure
│   │   ├── acr.bicep            # Container Registry infrastructure
│   │   └── types.bicep          # Shared type definitions
│   ├── scripts/                 # Deployment scripts
│   │   ├── deploy-aca.sh        # Container Apps deployment
│   │   ├── deploy-acr.sh        # Container Registry deployment
│   │   ├── test-aca.sh          # Post-deployment testing
│   │   └── create-wiki-page.sh  # Documentation generation
│   ├── templates/               # Pipeline templates
│   │   └── builds/              # Build job templates
│   │       ├── build-aca.yaml   # Container Apps deployment job
│   │       ├── build-app.yaml   # .NET application build job
│   │       ├── build-basic-infra.yaml # ACR infrastructure job
│   │       ├── build-images.yaml # Docker image build job
│   │       ├── create-wiki.yaml # Documentation generation job
│   │       └── test-deployment.yaml # Post-deployment testing job
│   ├── vars/                    # Configuration variables
│   │   ├── vars-global.yaml     # Global configuration
│   │   ├── vars-dev.yaml        # Dev configuration
│   │   ├── vars-tst.yaml        # Test configuration
│   │   ├── vars-prd.yaml        # Production configuration
│   │   └── locations/           # Location-specific settings
│   │       ├── location-eus.yaml # East US region configuration
│   │       └── location-weu.yaml # West Europe region configuration
│   ├── album-release.yaml       # Multi-environment pipeline
│   └── security-scan.yaml       # Security scanning pipeline #placeholder
└── .github/                     # GitHub configuration
    ├── dependabot.yml           # Dependency updates
```

## 🚀 Deployment Process

### Automated Deployment Flow

1. **Code Commit**: Developer merge PR from fork to main branch
2. **Build Trigger**: Azure DevOps pipeline automatically starts
3. **Application Build**: .NET app compilation and testing
4. **Infrastructure Provisioning**: Bicep templates deploy Azure resources
5. **Image Creation**: Docker image built and pushed to ACR
6. **Container Deployment**: New revision deployed to Container Apps
7. **Health Validation**: Automated testing of deployed endpoints
8. **Documentation**: Wiki pages updated with deployment details

### Manual Deployment Commands

To run this commands requires active subscrition and resource group

```bash
az login
# Deploy to DEV environment
./iac/scripts/deploy-acr.sh DEV eus 123
./iac/scripts/deploy-aca.sh DEV eus 123 abc456

# Test deployment
./iac/scripts/test-aca.sh album-api-dev rg-album-containerapps-DEV 1.1.0

# Generate documentation
./iac/scripts/create-wiki-page.sh DEV eus
```

## 

### Infrastructure Features
- **Modular Bicep Templates**: Reusable infrastructure components with functions, creating parameters on fly
- **Parameter Validation**: Strong typing with custom Bicep types
- **Environment Isolation**: Complete separation between DEV/TST/PRD
- **Security Integration**: ACR authentication with Container Apps
- **Monitoring Ready**: Log Analytics integration for observability

### Pipeline Features
- **Approvers**: Pre-run approval step
- **Job Dependencies**: Proper execution order with failure handling
- **Template-based Builds**: Reusable YAML templates for consistent job definitions across environments and regions
- **Documentation**: Automated wiki generation for deployments
- **Multi-Region**: Support for deployments across Azure regions


##  Future Enhancements

### Infrastructure as Code (IaC) Improvements

#### 1. **Blue-Green Deployment for ACA**
- **Purpose**: Implement zero-downtime deployments with instant rollback capability (https://learn.microsoft.com/en-us/azure/container-apps/blue-green-deployment?pivots=bicep)
- **Benefits**: Eliminates service interruption during updates and provides immediate fallback to previous version if issues arise

#### 2. **Use Managed Identity**
- **Purpose**: Replace admin user authentication with Azure Managed Identity for ACR access
- **Benefits**: Enhanced security by eliminating stored credentials and following Azure security best practices

#### 3. **Infrastructure for Alerts**
- **Purpose**: Create Bicep templates for Azure Monitor alerts and action groups
- **Benefits**: Proactive monitoring of application health, performance metrics, and automatic incident response

#### 4. **Advanced Monitoring (Prometheus)**
- **Purpose**: Implement Prometheus metrics collection for detailed application insights
- **Benefits**: Custom metrics, advanced alerting rules, and integration with Grafana dashboards for comprehensive observability

### GitHub Workflow Enhancements

#### 1. **Pull Request Rules**
- **Purpose**: Implement branch protection rules, required reviewers, and status checks
- **Benefits**: Ensures code quality, prevents direct pushes to main branch, and enforces peer review process

#### 2. **Tag-based Releases**
- **Purpose**: Automate release creation and deployment triggered by Git tags
- **Benefits**: Semantic versioning, automated changelog generation, and clear release tracking

#### 3. **Release Candidate Deployments**
- **Purpose**: Deploy from release candidates rather than feature branches
- **Benefits**: Stable deployment artifacts, better release management, and separation of development from production releases
