If you get access to AWS you might be able to find some next clues 

You can use AWS via the command line like so 

![[AWS.png]]

In this case we utilized AWS to gather the ssh key that we then used to crack if we want to download files on this machine the commands will be listed below

Key commands
---
Setting up a profile (we use this to authenticate)
`aws configure --profile $profilename$`

Listing items in a directory
`aws s3 ls --endpoint-url http://$target:$port`

Downloading items to the local machine 
`aws s3 sync s3://$bucketname/dir/ ./$LOCALDIRTOCOPY --endpoint-url http://$target:$port --profile $profilename`
