import glob
import os

try:
    from configparser import ConfigParser
except ImportError:
    from ConfigParser import ConfigParser


def get_modules_state(installroot):
    cfgdir = os.path.join(installroot, 'etc/dnf/modules.d')
    cfg = ConfigParser()
    cfg.read(glob.glob(cfgdir + '/*.module'))
    cfg_dict = dict()
    for section in cfg.sections():
        section_dict = dict(cfg.items(section))
        if section_dict.get('profiles'):
            section_dict['profiles'] = set(
                [p.strip() for p in section_dict['profiles'].split(',')])
        else:
            section_dict['profiles'] = set()
        cfg_dict[section] = section_dict
    return cfg_dict

