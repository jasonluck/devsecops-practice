# Application Pipeline Stages

Tools to develop your CI pipelines include:
* [GitHub Actions]()
* [AWS CodeDeploy]()
* [Azure Devops]()
* [Jenkins]()

## Compile
In each section cover
 - Purpose
 - Key Performance Indicators
 - Tools

## Unit Testing
This stage in the pipeline verifies the functionality of individual code functions.  These test cases are the easiest to write and usually offer the most control for testing exception cases. The quality gates we are looking to validate here are:
* All unit tests are passing
* Code coverage of the unit tests is greater than the projects defined threshold. We recommend 90% as the goal.

Typically these unit test cases are written by the developers, often using the same programming language that the application is written in. This means that unit test execution is often done through the same tool that is used to compile the code. Tools such as:
* [Maven]() or [Gradle]() for Java projects
* [dotnet test]() for .Net projects
* [Apex tests](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_unit_tests.htm#:~:text=Unit%20tests%20are%20class%20methods,annotation%20in%20the%20method%20definition.) for Salesforce projects

Key Performance Indicators (KPI) include:
* Percentage of code executed by the unit tests (Code Coverage)
* Number of unit tests

## Static Code Analysis
Static code analysis tools review the source code directly to look for insecure and problematic codeing patterns. The goal of this stage is to try and catch potential security issues, assess the maintainability of the codebase, and help enforce good coding standards. Tools that can be used for this analysis include:
* [SonarQube]() for application source code
* [Fortify](https://www.microfocus.com/en-us/cyberres/application-security/static-code-analyzer) for security scanning
* [tfsec](https://github.com/aquasecurity/tfsec) and [checkov](https://www.checkov.io/) for Terraform code
* [detect-secrets](https://github.com/Yelp/detect-secrets) monitors for sensitve data commited into the codebase



Key Performance Indicators (KPI) include:
* Number of issues found by severity
* Percentage of code duplication
* Cyclomatic complexity

## Package
During this stage you want to package your application for deployment/installation. The package should versioned be placed into an Artifact Repository where consumers can download it from. Examples of package repositories include:
* Nexus
* Artifactory
* GitHub Packages
* AWS CodeArtifact
* Azure Artifacts


## Deployment
The Deployment stage involves publishing your build output to a location where it can be tested. This can be very different depending our your artifacts, but there are a few common practices to consider when creating your deployment process:

* Parameterize the deployment target. As project evolve, you will likely need to support multipl environments in which to deploy your artifacts. Make sure your process can take this information as parameter so its flexible enough to support this requirement.
* Source control the deployment configuration. Your artifact is likely to need different deployment configurations depending on the deployment target. These configurations should be managed under source control to ensure consistency and repeatability.
* Consider emphemeral deployments. If your platform and artifact supports it, consider using emphemeral deployment environments for your testing. This concept allows for easily testing multiple builds in parallel and increases the consistency of the test environment.

Tools to support this process vary depending on your artifacts and platform, but some popular tools include:
* [Helm](https://helm.sh/) - Deployment and package manager for Kubernetes
* [Terraform](https://www.terraform.io/) - Configuration management tool for cloud infrastructure
*

## Testing
This is argueably the most important phase of your pipeline. Without good testing practices, you will never be able to reach a goal of continous delivery. Its these practices that build the stakeholder confidence that is required to get their approval for automated deployments to production.

When testing your artifact you want to strive for consistency and reliability of your test cases. If, given the same input, they don't generate the same result EVERY time then stakeholders will lose confidence in these tests and they are completely worthloss. They will also cost your team precious time running down test failure causes when its just a poorly written test.

Given this goal, some key things to consider when developing your testing process are:
* Test Data Management - When data is needed by a test case, we need to make sure to seed that data every test execution. We don't want to assume the state of the needed data or rely on the state of data in some integrated system.
*
### Integration Testing

### Performance Testing

### Security Testing


# Examples
