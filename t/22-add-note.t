use v6.c;
use Test;
use App::Tasks;

use File::Temp;

class MockInFH {
    has @.lines;

    method get(-->Str) {
        return shift @!lines;
    }

    method t(-->Bool) { False }
}

sub tests {
    my $tmpdir = tempdir.IO;    # Get IO::Path object for tmpdir.
    note "# Using directory {$tmpdir.Str}";

    my $task = App::Tasks.new( :data-dir($tmpdir) );

    my @lines = (
        'Subject Line',
        'n',
        '',
    );
    $task.INFH = MockInFH.new( :lines(@lines) );
    is $task.task-new(), "00001", "Added new task";

    my @tasks = $task.read-tasks;
    is @tasks.elems, 1, "Proper number of tasks exist (A)";
    is @tasks[0]<header><title>, "Subject Line", "Proper subject line (1)";
    is @tasks[0]<number>, 1, "Proper number (A1)";

    $task.task-add-note(1, "A Note.");

    @tasks = $task.read-tasks;
    is @tasks.elems, 1, "Proper number of tasks exist (B)";
    is @tasks[0]<header><title>, "Subject Line", "Proper subject line (B)";
    is @tasks[0]<number>, 1, "Proper number (B1)";
    is @tasks[0]<body>.elems, 1, "Proper number of body elements";
    is @tasks[0]<body>[0]<body>, "A Note.\n", "Proper body text";
    ok @tasks[0]<body>[0]<date>:exists, "Date field exists";
    ok @tasks[0]<body>[0]<date>.defined, "Date field defined";

    is $task.LOCKCNT, 0, "Lock count is 0";

    done-testing;
}

tests();
