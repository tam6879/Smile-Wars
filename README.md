# Smile-Wars
This program must be opened in the mono build of Godot. In order to get it to work, open editor settings, then scroll down to Dotnet editor. Select Visual Studio Code as the editor.
Additionally, you need to add two additional NuGet Packages. These packages are MongoDB.Driver.Core, and MongoDB.Driver.
There is also a line of code you will need to edit. Before you do this, ensure that you have added a user with read and write access inside of your MongoDB cluster. Inside of MongoInterface.cs, you will see a line names string uri. This line will look something like this:

string uri = "mongodb+srv://`<username>`:`<password>`@smile-war.b7xfs.mongodb.net/?retryWrites=true&w=majority&appName=Smile-War";

First, go into your MongoDB cluster and create a database named Smile-War. When you go to the instructions on how to connect to that database, copy the new uri string and replace the above code with it. Afterwards, replace the `<username>` with the name of your MongoDB user, and the `<password>` with that user's password. After this, you should be able to upload maps and load them into the game.
