test_all:
	clear && forge test -vv

t:
	clear && forge test -vv --match-test test_withdraw
tl:
	clear && forge test -vvvv --match-test test_withdraw

spell:
	clear && cspell "**/*.*"