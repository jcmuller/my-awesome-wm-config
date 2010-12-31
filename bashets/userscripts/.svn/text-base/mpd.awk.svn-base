#!/bin/awk -f

BEGIN {
	MPD_CMD = "mpc"; # mpd

	MPD_CMD | getline;
	MPD_CMD | getline;
		mpd_state = $1;
	close(MPD_CMD);
	
	if ( mpd_state == "[playing]" )
		print "▶";
	else
		{
		if ( mpd_state == "[paused]" )
			print "❚❚";
		else
			{
				print "■";
			}

		}
	}
