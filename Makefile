all: aappg

%: %.vala
	valac --pkg gtk+-3.0 $<

clean:
	rm aappg