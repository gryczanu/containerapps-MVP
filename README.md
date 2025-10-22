# Azure Container Apps Album API - MVP Project

This project demonstrates a complete Infrastructure as Code (IaC) implementation for deploying a .NET web API to Azure Container Apps. It's based on the [Azure Container Apps code-to-cloud quickstart](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote) with enhanced enterprise-grade infrastructure automation.

## 🏗️ Project Overview

This repository contains:
1. **Backend Web API** - backend web API service that returns a static collection of music albums
2. **Infrastructure as Code** - Complete Azure infrastructure automation using Bicep
3. **CI/CD Pipelines** - Azure DevOps pipelines for automated deployment
4. **Multi-environment Support** - DEV, TEST*, and PROD* environment configurations

## 🖥️ Backend Web API

### Technology Stack
- **.NET 6.0** - C# web API framework
- **ASP.NET Core** - Web framework for building HTTP services
- **Docker** - Containerization for consistent deployments
- **Azure Container Apps** - Serverless container hosting platform
- **GitHub** - Git repository
- **dependabot** - Monitor vulnerabilities in dependencies used in your project and keep your dependencies up-to-date

## 🏗️ Infrastructure as Code (IaC)

### Azure Resources

#### 🔒 **Azure Container Registry (ACR)**
- **Purpose**: Private Docker container registry for storing application images
- **SKU**: Basic tier for development environments
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
│                        │ │ • Health    │ │                │
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
  - Bicep template validation
  - ACR resource provisioning

#### 📦 **Image Build Job**
- **build-images.yaml**: Docker image creation and publishing
  - Docker image building from Dockerfile
  - Image tagging with build ID and version
  - Push to Azure Container Registry

#### 🚀 **Deployment Job**
- **build-aca.yaml**: Container Apps deployment
  - Bicep template deployment for Container Apps

#### ✅ **Testing Job**
- **test-deployment.yaml**: Post-deployment validation
  - Container Apps health verification
  - Endpoint testing and validation
  - Revision status monitoring

#### 📝 **Documentation Job**
- **create-wiki-page.sh**: Automated documentation generation
  - Container Apps revision status collection
  - Deployment information gathering
  - Wiki page creation with markdown formatting
  - Latest revision details (name, state, creation time, traffic weight)

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
│   ├── vars/                    # Configuration variables
│   │   ├── vars-DEV.yaml        # Development environment
│   │   ├── vars-TEST.yaml       # Test environment
│   │   ├── vars-PROD.yaml       # Production environment
│   │   └── locations/           # Location-specific settings eus or wue
│   ├── album-release.yaml       # Multi-environment pipeline
│   └── deploy-pipeline.yml      # Main deployment pipeline
└── .github/                     # GitHub configuration
    ├── dependabot.yml           # Dependency updates
    └── workflows/               # GitHub Actions (future)
```

## 🚀 Deployment Process

### Automated Deployment Flow

1. **Code Commit**: Developer pushes code to feature branch
2. **Build Trigger**: Azure DevOps pipeline automatically starts
3. **Application Build**: .NET app compilation and testing
4. **Infrastructure Provisioning**: Bicep templates deploy Azure resources
5. **Image Creation**: Docker image built and pushed to ACR
6. **Container Deployment**: New revision deployed to Container Apps
7. **Health Validation**: Automated testing of deployed endpoints
8. **Documentation**: Wiki pages updated with deployment details

### Manual Deployment Commands

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
- **Modular Bicep Templates**: Reusable infrastructure components
- **Parameter Validation**: Strong typing with custom Bicep types
- **Environment Isolation**: Complete separation between DEV/TEST/PROD
- **Security Integration**: ACR authentication with Container Apps
- **Monitoring Ready**: Log Analytics integration for observability

### Pipeline Features
- **Job Dependencies**: Proper execution order with failure handling
- **Parallel Execution**: Optimized build times where possible
- **Error Handling**: Comprehensive validation and rollback mechanisms
- **Documentation**: Automated wiki generation for deployments
- **Multi-Region**: Support for deployments across Azure regions

### Operational Features
- **Health Monitoring**: Liveness and readiness probes
- **Auto Scaling**: HTTP-based scaling rules
- **Blue-Green Deployments**: Zero-downtime deployments
- **Revision Management**: Automatic traffic shifting and rollback
- **Centralized Logging**: All logs forwarded to Log Analytics
