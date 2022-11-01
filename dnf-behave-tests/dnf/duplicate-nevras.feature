Feature: handling of packages with duplicate NEVRAs


# We use a skeleton repo with just primary, not even packages are present
# but we can check what paths dnf tries to open
Background: Prepare repo sekeleton with just uncompressed primary xml
Given I create directory "/repodata/"
  And I create file "/repodata/repomd.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <repomd xmlns="http://linux.duke.edu/metadata/repo" xmlns:rpm="http://linux.duke.edu/metadata/rpm">
        <data type="primary">
          <location href="repodata/primary.xml"/>
        </data>
      </repomd>
      """


Scenario: When duplicate nevras are present try to install older (by buildtime) package which is first in metadata
Given I create file "/repodata/primary.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <metadata xmlns="http://linux.duke.edu/metadata/common" xmlns:rpm="http://linux.duke.edu/metadata/rpm" packages="2">
      <package type="rpm">
        <name>labirinto</name>
        <arch>x86_64</arch>
        <version epoch="0" ver="1.0" rel="1.fc29"/>
        <checksum type="sha256" pkgid="YES">08439ea90b32515664b82a86bd8fa606f672290f301e979aa424a90b1d81868b</checksum>
        <summary>Made up package</summary>
        <description>labirinto description</description>
        <packager></packager>
        <url>None</url>
        <time file="1000" build="1000"/>
        <size package="6098" installed="0" archive="124"/>
        <location href="older/labirinto-1.0-1.fc29.x86_64.rpm"/>
        <format>
          <rpm:license>GPLv3+</rpm:license>
          <rpm:vendor></rpm:vendor>
          <rpm:group>Unspecified</rpm:group>
          <rpm:buildhost>ovpn-192-164.brq.redhat.com</rpm:buildhost>
          <rpm:sourcerpm>labirinto-1.0-1.fc29.src.rpm</rpm:sourcerpm>
          <rpm:header-range start="4504" end="6049"/>
          <rpm:provides>
            <rpm:entry name="labirinto" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
            <rpm:entry name="labirinto(x86-64)" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
          </rpm:provides>
        </format>
      </package>
      <package type="rpm">
        <name>labirinto</name>
        <arch>x86_64</arch>
        <version epoch="0" ver="1.0" rel="1.fc29"/>
        <checksum type="sha256" pkgid="YES">f92497e682e735be57ba989eac03ceb8c6fe6ed2ec9da96631d389c3200d2248</checksum>
        <summary>Made up package</summary>
        <description>labirinto description</description>
        <packager></packager>
        <url>None</url>
        <time file="1667299500" build="1667299500"/>
        <size package="6098" installed="0" archive="124"/>
        <location href="newer/labirinto-1.0-1.fc29.x86_64.rpm"/>
        <format>
          <rpm:license>GPLv3+</rpm:license>
          <rpm:vendor></rpm:vendor>
          <rpm:group>Unspecified</rpm:group>
          <rpm:buildhost>ovpn-192-164.brq.redhat.com</rpm:buildhost>
          <rpm:sourcerpm>labirinto-1.0-1.fc29.src.rpm</rpm:sourcerpm>
          <rpm:header-range start="4504" end="6049"/>
          <rpm:provides>
            <rpm:entry name="labirinto" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
            <rpm:entry name="labirinto(x86-64)" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
          </rpm:provides>
        </format>
      </package>
      </metadata>
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/               |
   When I execute dnf with args "install labirinto"
   Then stderr matches line by line
   """
   Error opening /tmp/dnf_ci_installroot_......../older/labirinto-1.0-1.fc29.x86_64.rpm: No such file or directory
   Package "labirinto-1.0-1.fc29.x86_64" from local repository "testrepo" has incorrect checksum
   Error: Some packages from local repository have incorrect checksum
   """


Scenario: When duplicate nevras are present try to install newer (by buildtime) package which is first in metadata
Given I create file "/repodata/primary.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <metadata xmlns="http://linux.duke.edu/metadata/common" xmlns:rpm="http://linux.duke.edu/metadata/rpm" packages="2">
      <package type="rpm">
        <name>labirinto</name>
        <arch>x86_64</arch>
        <version epoch="0" ver="1.0" rel="1.fc29"/>
        <checksum type="sha256" pkgid="YES">08439ea90b32515664b82a86bd8fa606f672290f301e979aa424a90b1d81868b</checksum>
        <summary>Made up package</summary>
        <description>labirinto description</description>
        <packager></packager>
        <url>None</url>
        <time file="1667299500" build="1667299500"/>
        <size package="6098" installed="0" archive="124"/>
        <location href="newer/labirinto-1.0-1.fc29.x86_64.rpm"/>
        <format>
          <rpm:license>GPLv3+</rpm:license>
          <rpm:vendor></rpm:vendor>
          <rpm:group>Unspecified</rpm:group>
          <rpm:buildhost>ovpn-192-164.brq.redhat.com</rpm:buildhost>
          <rpm:sourcerpm>labirinto-1.0-1.fc29.src.rpm</rpm:sourcerpm>
          <rpm:header-range start="4504" end="6049"/>
          <rpm:provides>
            <rpm:entry name="labirinto" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
            <rpm:entry name="labirinto(x86-64)" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
          </rpm:provides>
        </format>
      </package>
      <package type="rpm">
        <name>labirinto</name>
        <arch>x86_64</arch>
        <version epoch="0" ver="1.0" rel="1.fc29"/>
        <checksum type="sha256" pkgid="YES">f92497e682e735be57ba989eac03ceb8c6fe6ed2ec9da96631d389c3200d2248</checksum>
        <summary>Made up package</summary>
        <description>labirinto description</description>
        <packager></packager>
        <url>None</url>
        <time file="1000" build="1000"/>
        <size package="6098" installed="0" archive="124"/>
        <location href="older/labirinto-1.0-1.fc29.x86_64.rpm"/>
        <format>
          <rpm:license>GPLv3+</rpm:license>
          <rpm:vendor></rpm:vendor>
          <rpm:group>Unspecified</rpm:group>
          <rpm:buildhost>ovpn-192-164.brq.redhat.com</rpm:buildhost>
          <rpm:sourcerpm>labirinto-1.0-1.fc29.src.rpm</rpm:sourcerpm>
          <rpm:header-range start="4504" end="6049"/>
          <rpm:provides>
            <rpm:entry name="labirinto" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
            <rpm:entry name="labirinto(x86-64)" flags="EQ" epoch="0" ver="1.0" rel="1.fc29"/>
          </rpm:provides>
        </format>
      </package>
      </metadata>
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/               |
   When I execute dnf with args "install labirinto"
   Then stderr matches line by line
   """
   Error opening /tmp/dnf_ci_installroot_......../newer/labirinto-1.0-1.fc29.x86_64.rpm: No such file or directory
   Package "labirinto-1.0-1.fc29.x86_64" from local repository "testrepo" has incorrect checksum
   Error: Some packages from local repository have incorrect checksum
   """
