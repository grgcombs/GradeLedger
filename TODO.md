TODO 
==============

- Make this app not act like a spoiled-freaking-brat.  It certainly doesn't have the polish of something Steve Jobs would be proud of.

- Keyboard navigation needs work, now that we have NSArrayControllers jerking around table views.

- Rethink lots of the ugliness in the code.  There's not much inner beauty yet.

- I haven't touched memory monitoring and leak checking.  It should have a pretty rigorous go around with Instruments on CPU usage too.  Attendance and scores are slow once you get several students and assignments.

- I'm reluctant to just turn on Garbage Collection simply because it's available on OS X.  What if we turn this into an iPad app?  What then?

- The grade formula business is black magic. It shouldn't be.

- The grade calculations are correct *for my classes*, but I'm  suspicious that they're too fragile.

- Printing and exporting are just ass.

- I have _really_ *rudimentary* support for importing students via JSON, and equally rudimentary support for exporting lots of info via JSON.