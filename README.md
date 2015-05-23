# GooglePlacesAPItoSQL
For inserting places information from google api directly to our db we can use this project to generate the insert query.

For url keys, status, json structure explanation                        
Go to : https://developers.google.com/places/webservice/search          
                                                                              
For this example I am searching restaurant, night_club, bar in sydney     

And my insert query is like that                                        
                                                                              
      INSERT INTO `venue`( `cityid`, `hostid`, `latitude`, `longitude`,`openingtime`, `closingtime`, `type`, `address`, `description`,`venuename`, `isvisible`, `capacity`, `ispublic`) VALUES  ([value-1],[value-2],[value-3],[value-4],[value-5],[value-6],[value-7],[value-8],[value-9],[value-10],[value-11],[value-12],[value-13])        
