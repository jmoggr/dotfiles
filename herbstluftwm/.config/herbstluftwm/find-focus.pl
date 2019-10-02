#!/usr/bin/perl

use Text::Balanced 'extract_bracketed';

while (<>) {

    my $windowID = "";
    my $selection = 0;
    my $running=1;
    my $origional_layout = "";
    my $layout_back = "";

    if ($_ =~ s/([^;]*)\;//)
    {
        $windowID = $1;
    }
    else
    {
        print "Error: No suiteable window ID found to insert\n";
        exit 1;
    }

    $origional_layout = $_;
    $layout_back = $_;

    while ($running == 1)
    {
        if ($layout_back =~ s/^ *\(split (horizontal|vertical)\:[01]\.[0-9]{6}\:(0|1) //)
        {
            $selection = $2;

            my @result = extract_bracketed($layout_back, '()');

            if ($selection == 1)
            {
                $layout_back = join("", @result[1,-1]);
            }
        }
        elsif ($layout_back =~ /^ *\(clients max:[0-9] (0x[0-9a-z]+).*/)
        {
            $running = 0;
            print "Error: Focused frame already has a window\n";
            exit 1;
        }
        elsif ($layout_back =~ s/^ *\(clients max:0//)
        {
            $running = 0;

            (my $layout_front = $origional_layout) =~ s/\Q$layout_back\E$//;

            my $new_layout = $layout_front . " " . $windowID  . $layout_back;

            print "$new_layout\n";
        }
    }
}
