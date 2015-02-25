automation-challenges
=====================

Coding challenges for the VBS Automation Team

Coder-Notes
===========

* configuration mangement
  * I went with BaSH for this - because with ALL the configuration management options out there, if you're resoriting to writing a script - something has probably gone wrong already.  You'd be in a hurry, and you wouldn't want to waste time fiddling with modules/classes etc.  I don't think this would be a desired long term solution.

* log parser
  * probably the easiest of the requests, not just in scope but because borrowing existing modules makes for ezmode.  I took my normal route of POC 'script' style functionality - but written and commented in a way that would make it easy to convert the logic to a subclass of the log-parser-master class.

* rest api
  * I'd already demonstrated top-to-bottom scripting, and simple object/model php examples, so I went a little overkill using laravel here to demonstrate pure object-oriented/MVC-architecture understanding here - In addition any project that starts as a "simple rest" is destined to scale, and having a framework in place will make a lot of tedius stuff simpler later (actual HTML integration, multiple models, client requests etc )

Instructions
============

* Fork this repository to your github account
 * Complete each challenge in whatever order you want, at whatever pace you want. There is no time limit.
 * Be as complex or as simple as you want, and use whatever language you want. Sometimes we are looking for complex code solutions, other times we are not. The language used is not really a point of concern.
 * It is okay to rely on other existing frameworks, libraries or tools to accomplish goals. If you can do the same task with less code by just gluing some existing things together, that will make us very happy. Don't feel like you have to reinvent the wheel!
 * Documented solutions are better than undocumented ones
 * Solutions with good, useful tests are better than solutions without good, useful tests
 * Above all, your solutions must run. If it is okay for a solution to not run, or to be untested, the README in that project will note such.
* When you are done with the challenges, send a Pull Request, and we'll get back to you
