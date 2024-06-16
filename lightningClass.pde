int last_eaten = -1;

class Antbot {
    float X , Y , angle;              // coordinates, direction of movement
    boolean searchingBlue = true;     // seaching for blue?
    boolean screenYellow, screemBlue; // don't forget to shout
    float angleYellow, angleBlue;     // estimated direction to the bases
    float distYellow, distBlue;       // estimated distance  to the bases
    boolean dead;
    PImage img;
    
    
    
    
    

  //=======================================
  //======   constructor  =================
  //======================================= 
    Antbot( float X , float Y , float angle , boolean blue ){
      this.X = X;
      this.Y = Y;
      this.angle = angle;
      this.searchingBlue = blue;
      screenYellow = false; 
      screemBlue = false;
      angleYellow = random(0,TAU);
      angleBlue = random(0,TAU);
      distYellow = 100; 
      distBlue = 100;
      dead = false;
      img = loadImage("insect.png");

    }
    
   //===========================================
   //=====   agent makes a move  ===============
   //===========================================
   void step(boolean communicate) {
     float speed = 2;
     distYellow += 10;  distBlue += 10;   // distance counters increase
     angle += random(-0.05, 0.05);          // agent go crooked  
     // if the agent has reached the edge of the screen, then turn  ----------
     if (X<10|| X>width-10 || Y<10 || Y>height-10 ) angle = angle + PI;       
    
     X = X + sin(angle) * speed;                   // new coordinates
     Y = Y + cos(angle) * speed;
     color cl = get(int(X),int(Y));        // take a color sample at new coordinates
     

     
     if (communicate)
     {
        if ( cl == #FBCC69 ){       // if it is blue ----------- 
           searchingBlue = true;
           distBlue = 0;
           screemBlue = true;
           angle = angleYellow;
         } 
     
       //------ if time to screem ----------
       if( screemBlue ){                
         ScreemBlueDistance();
         screemBlue = false;          // reset the flag
         if( searchingBlue){ angle = angleBlue; }  // turn if needed
       } 
     }
 
   }
   
  //====================================================
  //========    draw agent   ===========================
  //====================================================
   void drawAgent(int size) {
     //if(searchingBlue) fill(#CBD4FF); 
     //else              fill(#FFEBC1); 
     //noStroke();
     
     //ellipse(X, Y, 10, 10);
     
    //int size = int(random(1, 4)); // Randomly selects 1, 2, or 3
    fill(#CBD4FF); 
    noStroke();
  
    if (size == 1 ) {
        //ellipse(X, Y, 10, 10);
        image(img, X, Y);
    } else if (size == 2) {
        ellipse(X, Y, 20, 20);
    } else if (size == 3) {
        fill(#D5515A);
        ellipse(X, Y, 100, 100);
    }
}
   
  //=========================================
  //--  set direction to yellow   -----------
  //=========================================
   void setAngleYellow(float x, float y, float d) { 
     float an = acos((y-Y)/d);
     if (x>X) {angleYellow = an;}
     else {angleYellow = TAU-an;}
   } 
   
  //=========================================
  //--  set direction to yellow   -----------
  //=========================================  
   void setAngleBlue(float x, float y, float d) { 
     float an = -acos((y-Y)/d);
     if (x>X) {angleBlue = an;}
     else {angleBlue = TAU-an;}
   }  

  //=====================================================
  //====   Screem the distance to the blue base     =====
  //===================================================== 
  void ScreemBlueDistance(){ 
    int dh2 = floor(distBlue);            // discard the fractional part
    int closestAntIndex = -1; // Variable to store the index of the closest ant
    float minDist = Float.MAX_VALUE;
    
    for (int i=0; i<agentsCount; i++){    //--- for all agents  ----
      if (ants[i].distBlue < minDist) {  // Check if the current ant's distance is less than the minimum distance found so far
        minDist = ants[i].distBlue;    // Update the minimum distance
        closestAntIndex = i;           // Update the index of the closest ant
      }
      
      if (ants[i].distBlue > dh2+1)       // if the agent's distance to the resource is greater  ----
      {
        
        float xz = ants[i].X;
        float yz = ants[i].Y;

        
        // roughly check that it is no further than the hearing distance -------
        if ( xz>X-hearDistance && xz<X+hearDistance && yz>Y-hearDistance && yz<Y+hearDistance){

          float d = dist( X,Y,xz,yz );    //---- calculate the exact distance
          
          if( d <= hearDistance ){        //---- if the agent is close

            ants[i].setAngleBlue(X,Y, -d);  //----   write to its variable (direction to the blue)
            ants[i].screemBlue = true;    //---- set flag to screem
            ants[i].distBlue = dh2+1;     //---- update its distance counter to the blue
            //----------  draw the link  --------------------------------
            //stroke(#99bbff,3);   strokeWeight(40);    line(X,Y,xz,yz);
            //stroke(#99bbff,15);  strokeWeight(20);    line(X,Y,xz,yz);  
            //stroke(#99bbff,50);  strokeWeight(9);     line(X,Y,xz,yz);
            //stroke(#ffbb99,255); strokeWeight(1);     line(X,Y,xz,yz);
            
            stroke(#ffff99,3);   strokeWeight(40);    line(X,Y,xz,yz);
            stroke(#ffff99,15);  strokeWeight(20);    line(X,Y,xz,yz);
            stroke(#ffff99,50);  strokeWeight(9);     line(X,Y,xz,yz);
            stroke(#ffff99,255); strokeWeight(1);     line(X,Y,xz,yz);
            //stroke(255);

              

  }}}}
  // After the loop, closestAntIndex holds the index of the closest ant
  ants[closestAntIndex].dead = true;
  if (closestAntIndex != last_eaten){
    soundEffect.trigger();
  }
  last_eaten = closestAntIndex;
} 
   
}
