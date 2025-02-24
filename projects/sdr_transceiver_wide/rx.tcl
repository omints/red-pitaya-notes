# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 8 DIN_FROM 0 DIN_TO 0
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 64 DIN_FROM 39 DIN_TO 0
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 64 DIN_FROM 40 DIN_TO 40
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 64 DIN_FROM 41 DIN_TO 41
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_4 {
  DIN_WIDTH 64 DIN_FROM 63 DIN_TO 48
}

# Create axis_constant
cell pavel-demin:user:axis_constant phase_0 {
  AXIS_TDATA_WIDTH 40
} {
  cfg_data slice_1/dout
  aclk /pll_0/clk_out1
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
  DDS_CLOCK_RATE 125
  SPURIOUS_FREE_DYNAMIC_RANGE 138
  FREQUENCY_RESOLUTION 0.2
  PHASE_INCREMENT Streaming
  HAS_PHASE_OUT false
  PHASE_WIDTH 30
  OUTPUT_WIDTH 24
  DSP48_USE Minimal
  NEGATIVE_SINE true
  RESYNC true
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk /pll_0/clk_out1
}

# Create port_slicer
cell pavel-demin:user:port_slicer adc_slice_0 {
  DIN_WIDTH 32 DIN_FROM 13 DIN_TO 0
}

# Create port_slicer
cell pavel-demin:user:port_slicer adc_slice_1 {
  DIN_WIDTH 32 DIN_FROM 29 DIN_TO 16
}

# Create axis_zeroer
cell pavel-demin:user:axis_zeroer zeroer_0 {
  AXIS_TDATA_WIDTH 16
} {
  s_axis_tdata adc_slice_0/dout
  s_axis_tvalid slice_2/dout
  aclk /pll_0/clk_out1
}

# Create axis_zeroer
cell pavel-demin:user:axis_zeroer zeroer_1 {
  AXIS_TDATA_WIDTH 16
} {
  s_axis_tdata adc_slice_1/dout
  s_axis_tvalid slice_3/dout
  aclk /pll_0/clk_out1
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS zeroer_0/M_AXIS
  S01_AXIS zeroer_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create cmpy
cell xilinx.com:ip:cmpy mult_0 {
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 24
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 26
} {
  S_AXIS_A comb_0/M_AXIS
  S_AXIS_B dds_0/M_AXIS_DATA
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk /pll_0/clk_out1
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 3
  M00_TDATA_REMAP {tdata[23:0]}
  M01_TDATA_REMAP {tdata[55:32]}
} {
  S_AXIS mult_0/M_AXIS_DOUT
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_4/dout
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_4/dout
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 25
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 24
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  S_AXIS_CONFIG rate_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 25
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 24
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  S_AXIS_CONFIG rate_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_1 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-2.6207935180e-08, -1.4554242328e-08, 2.3527789538e-08, 9.8906088568e-09, -1.1894225048e-08, 3.7024263607e-09, -1.1315490559e-08, -3.0439549565e-08, 4.8733610337e-08, 7.5443569211e-08, -1.0289700801e-07, -1.4479945928e-07, 1.7607313147e-07, 2.4554403253e-07, -2.7008172232e-07, -3.8562302696e-07, 3.8608923442e-07, 5.7378220469e-07, -5.2441088916e-07, -8.1941526484e-07, 6.8430132830e-07, 1.1323398409e-06, -8.6376335957e-07, -1.5225169134e-06, 1.0593621797e-06, 1.9996808382e-06, -1.2660909726e-06, -2.5729113485e-06, 1.4772608692e-06, 3.2500529570e-06, -1.6846759670e-06, -4.0375050023e-06, 1.8782148518e-06, 4.9390995151e-06, -2.0464245023e-06, -5.9557667007e-06, 2.1765944668e-06, 7.0847827911e-06, -2.2551536847e-06, -8.3191133925e-06, 2.2681191714e-06, 9.6466852478e-06, -2.2017771964e-06, -1.1049790571e-05, 2.0434299557e-06, 1.2504508634e-05, -1.7823217722e-06, -1.3980281196e-05, 1.4106151823e-06, 1.5439522978e-05, -9.2456566161e-07, -1.6837451270e-05, 3.2567937576e-07, 1.8121690297e-05, 3.7694497395e-07, -1.9234285704e-05, -1.1676480265e-06, 2.0109576066e-05, 2.0205036465e-06, -2.0676629075e-05, -2.8989070085e-06, 2.0859933203e-05, 3.7542162935e-06, -2.0580845374e-05, -4.5247911108e-06, 1.9759082254e-05, 5.1349235315e-06, -1.8314814880e-05, -5.4942699366e-06, 1.6170886561e-05, 5.4974757475e-06, -1.3255462936e-05, -5.0244351747e-06, 9.5046225099e-06, 3.9407728773e-06, -4.8652742748e-06, -2.0992055162e-06, -7.0326707208e-07, -6.6248544216e-07, 7.2198032313e-06, 4.5105340828e-06, -1.4687725489e-05, -9.6208115918e-06, 2.3085987687e-05, 1.6171875903e-05, -3.2367760946e-05, -2.4341056258e-05, 4.2457961887e-05, 3.4299235877e-05, -5.3251815095e-05, -4.6205679773e-05, 6.4613298671e-05, 6.0201688463e-05, -7.6374689493e-05, -7.6404014016e-05, 8.8336549275e-05, 9.4897243842e-05, -1.0026930903e-04, -1.1572629887e-04, 1.1191566423e-04, 1.3888777273e-04, -1.2299833908e-04, -1.6433290767e-04, 1.3320559752e-04, 1.9193365698e-04, -1.4222585122e-04, -2.2150074558e-04, 1.4973641180e-04, 2.5276616815e-04, -1.5541610078e-04, -2.8537742707e-04, 1.5895508057e-04, 3.1889130981e-04, -1.6006689199e-04, -3.5276992476e-04, 1.5850039747e-04, 3.8637688107e-04, -1.5405361261e-04, -4.1897547247e-04, 1.4658782725e-04, 4.4972737230e-04, -1.3604383267e-04, -4.7769381091e-04, 1.2245876506e-04, 5.0183666478e-04, -1.0599455059e-04, -5.2105319270e-04, 8.6903021110e-05, 5.3411244581e-04, -6.5621246053e-05, -5.3973503503e-04, 4.2737784605e-05, 5.3657664670e-04, -1.9020134223e-05, -5.2324397084e-04, -4.5691141547e-06, 4.9831037216e-04, 2.6856062884e-05, -4.6033526286e-04, -4.6442510531e-05, 4.0788351674e-04, 6.1693003901e-05, -3.3954741378e-04, -7.0724451536e-05, 2.5396808499e-04, 7.1395182376e-05, -1.4985851587e-04, -6.1294270813e-05, 2.6023122027e-05, 3.7703429918e-05, 1.1853854522e-04, 2.2706297377e-06, -2.8479617298e-04, -6.1911167648e-05, 4.7347532398e-04, 1.4476053386e-04, -6.8510913861e-04, -2.5465541629e-04, 9.2001014346e-04, 3.9573608909e-04, -1.1782477517e-03, -5.7245811874e-04, 1.4596258982e-03, 7.8960540427e-04, -1.7636652801e-03, -1.0523112540e-03, 2.0895865608e-03, 1.3660867119e-03, -2.4362988559e-03, -1.7368640566e-03, 2.8023923390e-03, 2.1710638317e-03, -3.1861423149e-03, -2.6757677605e-03, 3.5852673995e-03, 3.2584196806e-03, -3.9974852163e-03, -3.9276040747e-03, 4.4199394341e-03, 4.6928481025e-03, -4.8494136298e-03, -5.5649950698e-03, 5.2822960597e-03, 6.5566018507e-03, -5.7145409564e-03, -7.6824758455e-03, 6.1416100661e-03, 8.9604145387e-03, -6.5583843283e-03, -1.0412244808e-02, 6.9590202957e-03, 1.2065298475e-02, -7.3367246680e-03, -1.3954553400e-02, 7.6834020675e-03, 1.6125843048e-02, -7.9890888341e-03, -1.8641088709e-02, 8.2397931481e-03, 2.1583885843e-02, -8.4182820106e-03, -2.5074641134e-02, 8.4980078429e-03, 2.9289248383e-02, -8.4376369417e-03, -3.4496140986e-02, 8.1675764732e-03, 4.1125591045e-02, -7.5602012419e-03, -4.9911029383e-02, 6.3566552807e-03, 6.2206836265e-02, -3.9603317702e-03, -8.0800415552e-02, -1.2669945050e-03, 1.1238388819e-01, 1.5173808211e-02, -1.7720129710e-01, -7.0309146351e-02, 3.6089098813e-01, 6.1516397937e-01, 3.6089098813e-01, -7.0309146351e-02, -1.7720129710e-01, 1.5173808211e-02, 1.1238388819e-01, -1.2669945050e-03, -8.0800415552e-02, -3.9603317702e-03, 6.2206836265e-02, 6.3566552807e-03, -4.9911029383e-02, -7.5602012419e-03, 4.1125591045e-02, 8.1675764732e-03, -3.4496140986e-02, -8.4376369417e-03, 2.9289248383e-02, 8.4980078429e-03, -2.5074641134e-02, -8.4182820106e-03, 2.1583885843e-02, 8.2397931481e-03, -1.8641088709e-02, -7.9890888341e-03, 1.6125843048e-02, 7.6834020675e-03, -1.3954553400e-02, -7.3367246680e-03, 1.2065298475e-02, 6.9590202957e-03, -1.0412244808e-02, -6.5583843283e-03, 8.9604145387e-03, 6.1416100661e-03, -7.6824758455e-03, -5.7145409564e-03, 6.5566018507e-03, 5.2822960597e-03, -5.5649950698e-03, -4.8494136298e-03, 4.6928481025e-03, 4.4199394341e-03, -3.9276040747e-03, -3.9974852163e-03, 3.2584196806e-03, 3.5852673995e-03, -2.6757677605e-03, -3.1861423149e-03, 2.1710638317e-03, 2.8023923390e-03, -1.7368640566e-03, -2.4362988559e-03, 1.3660867119e-03, 2.0895865608e-03, -1.0523112540e-03, -1.7636652801e-03, 7.8960540427e-04, 1.4596258982e-03, -5.7245811874e-04, -1.1782477517e-03, 3.9573608909e-04, 9.2001014346e-04, -2.5465541629e-04, -6.8510913861e-04, 1.4476053386e-04, 4.7347532398e-04, -6.1911167648e-05, -2.8479617298e-04, 2.2706297377e-06, 1.1853854522e-04, 3.7703429918e-05, 2.6023122027e-05, -6.1294270813e-05, -1.4985851587e-04, 7.1395182376e-05, 2.5396808499e-04, -7.0724451536e-05, -3.3954741378e-04, 6.1693003901e-05, 4.0788351674e-04, -4.6442510531e-05, -4.6033526286e-04, 2.6856062884e-05, 4.9831037216e-04, -4.5691141547e-06, -5.2324397084e-04, -1.9020134223e-05, 5.3657664670e-04, 4.2737784605e-05, -5.3973503503e-04, -6.5621246053e-05, 5.3411244581e-04, 8.6903021110e-05, -5.2105319270e-04, -1.0599455059e-04, 5.0183666478e-04, 1.2245876506e-04, -4.7769381091e-04, -1.3604383267e-04, 4.4972737230e-04, 1.4658782725e-04, -4.1897547247e-04, -1.5405361261e-04, 3.8637688107e-04, 1.5850039747e-04, -3.5276992476e-04, -1.6006689199e-04, 3.1889130981e-04, 1.5895508057e-04, -2.8537742707e-04, -1.5541610078e-04, 2.5276616815e-04, 1.4973641180e-04, -2.2150074558e-04, -1.4222585122e-04, 1.9193365698e-04, 1.3320559752e-04, -1.6433290767e-04, -1.2299833908e-04, 1.3888777273e-04, 1.1191566423e-04, -1.1572629887e-04, -1.0026930903e-04, 9.4897243842e-05, 8.8336549275e-05, -7.6404014016e-05, -7.6374689493e-05, 6.0201688463e-05, 6.4613298671e-05, -4.6205679773e-05, -5.3251815095e-05, 3.4299235877e-05, 4.2457961887e-05, -2.4341056258e-05, -3.2367760946e-05, 1.6171875903e-05, 2.3085987687e-05, -9.6208115918e-06, -1.4687725489e-05, 4.5105340828e-06, 7.2198032313e-06, -6.6248544216e-07, -7.0326707208e-07, -2.0992055162e-06, -4.8652742748e-06, 3.9407728773e-06, 9.5046225099e-06, -5.0244351747e-06, -1.3255462936e-05, 5.4974757475e-06, 1.6170886561e-05, -5.4942699366e-06, -1.8314814880e-05, 5.1349235315e-06, 1.9759082254e-05, -4.5247911108e-06, -2.0580845374e-05, 3.7542162935e-06, 2.0859933203e-05, -2.8989070085e-06, -2.0676629075e-05, 2.0205036465e-06, 2.0109576066e-05, -1.1676480265e-06, -1.9234285704e-05, 3.7694497395e-07, 1.8121690297e-05, 3.2567937576e-07, -1.6837451270e-05, -9.2456566161e-07, 1.5439522978e-05, 1.4106151823e-06, -1.3980281196e-05, -1.7823217722e-06, 1.2504508634e-05, 2.0434299557e-06, -1.1049790571e-05, -2.2017771964e-06, 9.6466852478e-06, 2.2681191714e-06, -8.3191133925e-06, -2.2551536847e-06, 7.0847827911e-06, 2.1765944668e-06, -5.9557667007e-06, -2.0464245023e-06, 4.9390995151e-06, 1.8782148518e-06, -4.0375050023e-06, -1.6846759670e-06, 3.2500529570e-06, 1.4772608692e-06, -2.5729113485e-06, -1.2660909726e-06, 1.9996808382e-06, 1.0593621797e-06, -1.5225169134e-06, -8.6376335957e-07, 1.1323398409e-06, 6.8430132830e-07, -8.1941526484e-07, -5.2441088916e-07, 5.7378220469e-07, 3.8608923442e-07, -3.8562302696e-07, -2.7008172232e-07, 2.4554403253e-07, 1.7607313147e-07, -1.4479945928e-07, -1.0289700801e-07, 7.5443569211e-08, 4.8733610337e-08, -3.0439549565e-08, -1.1315490559e-08, 3.7024263607e-09, -1.1894225048e-08, 9.8906088568e-09, 2.3527789538e-08, -1.4554242328e-08, -2.6207935180e-08}
  COEFFICIENT_WIDTH 24
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 2
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 5.0
  CLOCK_FREQUENCY 125
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 25
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 3
  TDATA_REMAP {tdata[23:0]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_0 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 22
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A subset_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS fp_0/M_AXIS_RESULT
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 64
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 8192
  ALWAYS_READY TRUE
} {
  S_AXIS conv_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}
