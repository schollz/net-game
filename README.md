net-game
========

An adaptive game that uses current world data to produce an in-game world for the player to explore.

The reader, which scans the Internet for current information, is written in Python. Then, a Perl script parses through the data that was found and collects important information by searching for keywords and patterns. It passes this information onto a Common Lisp frontend which generates the world and interacts with the user.

There are a few shell scripts in the top-level directory that hold the system together. It is STRONGLY recommended that users use these, rather than trying to call the individual componenets themselves. A Windows user can download Cygwin to run the shell scripts. The `run.sh` script assumes Python 3 and Perl are both on the path. Additionally, the `play.sh` script assumes that GNU CLISP is on the path. However, any conforming Common Lisp implementation should work. If you wish to use a different one, supply the name as an argument when calling `play.sh`.

Commands in the game are entered at the command line. Use `help` in-game to get the list of commands. Note that the `quit` command will always exit the game, regardless of the current game mode.

This game (specifically, the Python part) accesses the Internet. Your antivirus software may not like that. This game ONLY accesses Wikipedia and pages on the Wikipedia domain; feel free to check the Python code to verify that this is the case. It also depends on the Wikipedia package for Python, which is available online and through `pip` for free and is usable under the MIT license.

Currently, I am in the process of adding a Ruby layer between the CLisp and Perl layers to do much of the world generation. The Ruby layer will use the Ruby Gem sxp, which is available through `gem` and is public domain.

#Dependencies

Note that Python, Perl, and Ruby are expected to be in /usr/bin. The Lisp implementation must be on the path.

######Python
* Python 3
* Wikipedia module (`pip install wikipedia`)

######Perl
* Perl 5.10 or newer (untested with Perl 6)
* JSON::PP (usually comes with Perl implementations)

######Ruby
* Ruby 1.9 or newer
* SXP gem (`gem install sxp`)

######Common Lisp
* Any conforming Common Lisp implementation (with CLOS)
(NOTE: The system defaults to assuming GNU CLISP is on the path. If you wish to use another implementation, you may have to pass its name as a command line argument to some scripts.)
