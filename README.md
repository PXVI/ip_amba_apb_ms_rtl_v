# ip_amba_apb_ms_rtl_v

<br />

This repository houses various amba apb master and slave protocol ip's. The protocol verison which is supported by the rtl's is **Arm's AMBA3** open standard protocol.<br />
The reason for adding verison numbers for the IP is that the RTL is funtionally stable in every aspect, but will need more user specific features in the future and if a new feature is added; it wil be provided as a stand alone IP built over the existing one.<br />
<br />

### Contents of the repository

  - APB3 Master Zero ( v00.00 )
    - Generic application interface
    - Heavy user control for transaction initiations
    - Parameterized interafce port widths
    - Fully compliant with the APB3 protocol
    - Complete granular support for interfacing with any kind of bridge
    - Additional support for the protocol timeout timers
  - APB3 Slave Zero ( v00.00 )
    - Generic memory supporting interface
    - Fully compliant with the APB3 protocol
    - Parameterized interafce port widths
    - Modifiable granularity
    - No support for timeouts
