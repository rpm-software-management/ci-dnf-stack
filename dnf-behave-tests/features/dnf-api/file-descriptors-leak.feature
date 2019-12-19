Feature: Check that dnf is not leaking file descriptors

@bz1594016
@bz1781360
Scenario:  libdnf sack is not leaking file descriptors
   When I execute python script
    """
    import dnf
    import os
    import sys

    def count_open_file_descriptors():
        return len(os.listdir('/proc/self/fd'))

    base = dnf.Base()
    open_fds = count_open_file_descriptors()
    for i in range(3):
        base.fill_sack(load_system_repo=False)
        base.reset(sack=True, repos=True, goal=True)
    base.close()
    sys.exit(count_open_file_descriptors() != open_fds)
    """
   Then the exit code is 0
