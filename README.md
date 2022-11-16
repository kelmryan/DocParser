# Automated Risk Assessment of Microservices

The  Automated Risk Assessment of Microservices(ARAM) is an automated CI/CD pipline that automates best security practices for 3rd party microservices. The risk assesment is done based on the researched security compliance by the OCIO team and in agreement with the AO in an effort to minimize risk while implementing best security practices.

## Jenkins Risk Assessment
The following will explain how to run the Jenkins automated Risk assessment using the gitlab pipeline. This pipeline will run security policy checks against an active jenkins server running in a specified environment. These checks are user in an attempt to identify the best security practices in accordance with:
- [CIS benchmark](https://www.cisecurity.org/cis-benchmarks/)
- [Jenkins Security instructions](https://www.jenkins.io/doc/book/security/securing-jenkins/)
- [SANS institute][https://www.sans.org/white-papers/36872/]

### Prerequisite
The following steps need to be taken prior to running the test.
- Access to [appstream](https://confluence.entapps.fbi.gov/display/FCS/FCS+AppStream+User+Guide)
- Access to gitlab on [primrosenet](https://confluence.entapps.fbi.gov/display/CLOUD/Cloud+Team+Onboarding)
- Access to the AMRA board on GDEV as a maintainer or higher
- Establish variables within gitlab project including:
```
BASTION - User and IP address of jump box
BASTION_PUB - Bastion public key
JENKINS - URL to Jenkins server being assessed
JENKINS_SERVER - User and IP address of Jenkins server
TOKEN - (Optional) Used for interacting with 
```
**NOTE** - This may require configuration and communication with the system owner of the Jenkins instance 

### Instructions
The following instructions will guide a user to running a Security assessment against a configured Jenkins server
1. **Browser**- Navigate to [app stream](https://appstream.cirrusdev.io/)
1. **Appstream**- Open a browser and click the gitlab icon
1. **Appstream**- Sign in to gitlab
1. **Appstream**- Navigate to gitlab.primrosenet.net/ISRM/aram/-/pipelines/new
1. **Appstream**- Click `Run Pipeline` button
1. **Appstream**- Wait 2-4 minutes for the jobs to run 
1. **Appstream**- Evaluate Jobs that passed or failed
1. **Appstream**- Click a job
1. **Appstream**- Download artifacts (passed or failed) and save to **Downloads** folder
1. **Appstream**- Open notepad++ on appstream
1. **Appstream**- Click `File -> open -> Downloads`
1. **Appstream**- Right click the `artifacts` and select `Extract All...`
1. **Appstream**- Click `Extract`
1. **Appstream**- Click `results` folder and then click the text file
1. **Appstream**- Verify information

For failures reference the Failed jobs section

#### Failed Jobs
1. **Browser**- Reference [Jenkins jobs](https://confluence.entapps.fbi.gov/display/RMRA/Jenkins)
1. **Browser**- Step through the **Manual Assessment** method of any jobs that may have failed
1. **Browser**- Verify solution and create issues as needed