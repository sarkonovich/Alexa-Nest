##Alexa Nest##

###Control Nest Thermostat with Alexa###


Since Amazon does not give 3rd party developers a way to access your local network, we need a bit of a workaround. This skill has two components:

1. An Amazon Alexa Lambda function -- thanks to [Matt Kruse](https://forums.developer.amazon.com/forums/profile.jspa?userID=13686) -- on AWS that just passes the Alexa request onto...

2. A server on your local network that does have access your Nest Thermosatat.

To deploy the Lambda function, you'll need to set up a developer account at the [developer portal.](https://developer.amazon.com/home.html)

For information on how to set up the Lambda function, look at the instructions [here.](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/developing-an-alexa-skill-as-a-lambda-function)

(In particular, follow the steps under "Creating a Lambda Function for an Alexa Skill")

Add your code as Node.js. Just copy and paste lambda_passthrough.js in the code editor.

Then in the Amazon [developer portal](https://developer.amazon.com/edw/home.html#/skills), you'll need to create a new skill.

1. For "Name" pick anything you want. How about 'Nest'
2. For "Invocation Name" pick anything you want. 'Nest' still works. This is the name you'll use to open the skill (e.g., "Alexa, tell Nest to....")
3. For "Version Number"...anything. How about 0.0.1?
4. For "Endpoint" select 'Lambda ARN' and point it to your Lambda function by filling in the field with the proper resource name. Just go to your Lambda Function in the AWS Console. The ARN will look something like this:  arn:aws:lambda:us-east-1:123456789805:function:my_function
5. On the next page fill in the interaction model, custom slot values, and utterance samples by copying and pasting the info from intent_schema.txt, custom_slots.txt. and sample_utterances.txt respectively.

That's it for setting up the skill in your Amazon Developer's account.

On your local machine copy (or unzip) all the files from this repo into a directory on your local machine.
Open up the file nest_device.rb and enter your Nest username/email and password on line 2 in the appropriate place. (Save and close the file.)

#####======================================================================
#####Note: If you are using this in conjunction with Alexa Hue, at this point you just need to a) copy nest.rb and nest_device.rb into the same directory as your Alexa Hue files (don't replace the Alexa Hue app.rb with the one included with Alexa Nest); b) Edit the Alexa Hue app.rb file so that:
````require './nest_device'````

is on the first line and

````register Sinatra::NestDevice````

is next to 
````register Sinatra::Lights````

Stop and restart you r sinatra server, and you should be all set.

If you're not using Alexa Nest with Alexa Hue.....read on!
#####========================================================================



The program requires ruby 2.0 or above,  sinatra, and a couple of Ruby Gems.

To install ruby, if you don't already have it, I suggest using RVM. Instructions are [here.](https://rvm.io/rvm/install)
After rvm is installed, install a recent version of ruby:

````rvm install 2.2.0 --disable-binary````


Place all files in the same directory. And then type


````gem install sinatra````

to install the sinatra web server. Then


````gem install httparty````
````gem install json````

Finally, 


````ruby app.rb````

to start the server on port 4567.

Almost done!

You need some way to expose the server to the internets. I like to use an [ngrok](https://ngrok.com/) tunnel.
Download the appropriate version of the program and start it up like this:

````./ngrok http 4567````

Andd you can add a bit of security by requiring basic auth credentials

````./ngrok http -auth="username:password" 4567````

(For a bit more security, uncomment the application id check on line 15 of lights.rb and plug in the application id of your skill from the developer's portal.)

If using ngrok, you'll end up looking at something like this, which is the public IP address of the tunnel to your local server.
                                                                                    
````Forwarding  http://bb1bde4a.ngrok.io -> localhost:4567````                                                                  
   
Finally, head back to the lambda function on aws and replace the application_id and url with the application_id of your skill (found in the developer portal) and the ip address of your server (e.g., the ip address of your ngrok tunnel.) So, line 9 (or so) of the Lambda function might look something like this:

```` 'amzn1.echo-sdk-ams.app.3be28e92-xxxx-xxxx-xxxx-xxxxxxxxxxxx':'http://username:password@bb1bde4a.ngrok.io/nest' ````

(If you end up using this alot, it would probably make sense to pay ngrok $5 and get a reserved address for you tunnel. That way you won't have to change the lambda function everytime you restart the ngrok tunnel.)


If you've added some basic auth to the tunnel, use the following format to specify the route to your local server in the lambda function:

    http://username:password@bb1bde4a.ngrok.io/nest
		
		
Once you have an ngrok tunnel running to your sinatra server, you should be all set. Just say 

````Alexa, launch Nest````

Alexa should respond with the current indoor temperature and thermostat setting. Then you can say,

````Alexa, set the heat to 69````

````Alexa, set the thermostat to away````

etc.
		


