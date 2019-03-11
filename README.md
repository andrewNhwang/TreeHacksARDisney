# TreeHacksARDisney

## What is it?
Our Disney Augmented app adds another level to the Disney experience. Navigating parks can always be a challenge to families, and paper and mobile maps can often be complicated and annoying. The Disney Augmented app provides real-time Augmented Reality navigation, allowing users to point their phone in the direction and get pinpoint locations with distances, and wait-times to sites of interest (in AR). Moreso, users can get additional information from the environment like seeing hovering AR displays from scanning ride signs and seeing additional live AR graphics of relevant Disney characters in the environments they are in. [Click here to preview the real-time Augmented Reality navigation used in Stanford's Campus] (https://youtu.be/XAflkYuwkHQ)

Second, our Disney augmented app adds additional ways for the users to engage in the environment in the form of mini-games. Users can use the app to interact with the park in novel ways such as embarking on a scavenger hunt for hidden mickeys using the app to track their progress and get hints.  [Click here to preview the Hidden Mickey Scavenger Hunt Game](https://imgur.com/a/AlUzhIr "Hidden Mickey Scavenger Hunt Game Demo!")

## Developing the App
We set up this project using Apple's ARKit with the goal in mind to create an Augmented Reality application for user's to use while in a Disney park. This project was composed of two verticals: 

1) A focus on a more user-friendly AR map to rides with information on rollercoasters 

2) A focus on designing an interactive game for tourists as they walked through the park or were idly standing in line

We iteratively developed a virtual world around any user and using data from their phone's kinetic sensors and live GPS data, we create a 3D coordinate system around them highlighting nearby landmarks and suspend information about each landmark in the real world. Further, we created an ARResource Group database of many pictures of Hidden Mickeys and created a detection algorithm that highlights when users have found a Hidden Mickey and we will create a plane in front of the Hidden Mickey and provide a special video and congratulations to the user.

## Challenges
In creating the AR Map software, we found it especially challenging to create persisting and localized labels that accurately showed users key landmarks around them with respect to user's locations. We made use of existing SLAM techniques and linear algebra abstractions to create accurate resizeable scaled mappings of user's surroundings using real-time data from the phone's sensor kinetics (such as the gyroscope and camera) and Google Map latitude and longitudinal data.  

In creating the Hidden Mickey Mouse Scavenger Hunt Game, we ran into hurdles with developing an algorithm to detect Hidden Mickeys. Ultimately we ended up creating a database of existing images of Hidden Mickeys and used computer vision techniques to find whether the camera feed detected the presence of a Hidden Mickey. 

## What's next for Disney Augmented
We hope we can continue to work on developing this AR experience and integrate it into Disney’s official mobile app for everyone to use. It’d be our dream come true to inspire others to dream bigger and to experience an immersive experience through this AR app. Our label can easily be integrated with the current Disney World app to include information such as wait time, height requirements, and accessibility services to accommodate all parties. In the future, we hope to create additional landmarks for users to take advantage of such as bathrooms, dining areas, shops, and other 'hidden secrets'.

At the moment, what's next for Disney Augmented is bringing signs to life - creating stronger visual and infographics that users can read on the go to make their Disney experience better. 

