Add-Type -assembly System.Windows.Forms 
Add-Type -assembly System.Drawing

#Image: 16x16px -> Button: 30x25

$adb_path = "$PWD\scrcpy-win64-v2.2\adb.exe"
$scrcpy_path = "$PWD\scrcpy-win64-v2.2\scrcpy.exe"
$network_speed_preset = @("No Limit", "128kbps","256kbps","1Mbps","5Mbps","15Mbps")
$buffer

class Android {
	[string]$serial
	[string]$model
	[int]$version
	[string]$ip_addr
	[int]$port
	[string]$auth
	
	[void] Clear(){
		$this.serial = ""
		$this.model = ""
		$this.version = 0
		$this.ip_addr = ""
		$this.port = 0
		$this.auth = ""
	}
}
$device = [Android]::new()

$GUI = {
	#Main Form
	$main_form = new-object System.Windows.Forms.Form
	$main_form.size = "365,300"
	$main_form.text = "Android Network Limiter"
	$main_form.StartPosition = "CenterScreen"
	$main_form.Add_Closing({&$closing_event_1})
	$main_form.Add_Shown({})
	$main_form.Add_Click({&$check_process})
	$main_form.Add_MouseHover({&$check_process})
	
	#Main Form Strip
	$main_strip = New-Object System.Windows.Forms.MenuStrip
	
	#File Option
	$file_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$file_option.Text = "File"
	$file_option.TextAlign = "MiddleLeft"
	$file_option.BackColor = "Control"
	$save_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$save_option.Text = "Save"
	$save_option.Add_Click({})
	$saveas_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$saveas_option.Text = "Save As"
	$saveas_option.Add_Click({})
	$open_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$open_option.Text = "Open"
	$open_option.Add_Click({})
	$line = New-Object System.Windows.Forms.ToolStripSeparator
	$exit_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$exit_option.Text = "Exit"
	$exit_option.Add_Click({})
	@($save_option,$saveas_option,$open_option,$line,$exit_option) | %{$file_option.DropDownItems.Add($_)}
	
	#Mode Option
	$mode_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$mode_option.Text = "Mode"
	$mode_option.TextAlign = "MiddleLeft"
	$mode_option.BackColor = "Control"
	$simple_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$simple_option.Text = "Simple"
	$simple_option.Add_Click({&$call_simple_panel})
	$slider_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$slider_option.Text = "Slider"
	$slider_option.Add_Click({&$call_slider_panel})
	$custom_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$custom_option.Text = "Custom"
	$custom_option.Add_Click({&$call_custom_panel})
	@($simple_option,$slider_option,$custom_option) | %{$mode_option.DropDownItems.Add($_)}
	
	#Settings Option
	$settings_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$settings_option.Text = "Settings"
	$settings_option.TextAlign = "MiddleLeft"
	$settings_option.BackColor = "Control"
	$update_option = New-Object System.Windows.Forms.ToolStripMenuItem
	$update_option.Text = "Check For Update"
	$update_option.Add_Click({})
	$settings_option.DropDownItems.Add($update_option)
	
	@($file_option,$mode_option,$settings_option) | %{$main_strip.Items.Add($_)}
	$main_strip.location = "0,0"
	$main_strip.Size = "340,25"
	$main_strip.GripStyle = "Visible"
	
	#Simple Panel
	$simple_panel = New-Object System.Windows.Forms.Panel
	$simple_panel.Location = "10,30"
	$simple_panel.Size = "330,95"
	$simple_panel.BackColor = "ButtonHighlight"
	$simple_panel.BorderStyle = "FixedSingle"
	$simple_panel.Visible = $True
	
	#Speed Label
	$speed_lbl = New-Object System.Windows.Forms.Label
	$speed_lbl.Size = "65,25"
	$speed_lbl.Location = "20,35"
	$speed_lbl.Text = "Speed:"
	$speed_lbl.Font = "Microsoft Segoe UI,10,style=Bold"
	
	#Preset Combobox (Simple Panel)
	$cmb_1 = New-Object System.Windows.Forms.ComboBox
	$cmb_1.size = "100,21"
	$cmb_1.location = "85,35"
	$network_speed_preset | %{$cmb_1.Items.Add($_)}
	$cmb_1.SelectedIndex = 0
	
	#Send Button (Simple Panel)
	$btn_1 = New-Object System.Windows.Forms.Button
	$btn_1.size = "75,30"
	$btn_1.location = "215,30"
	$btn_1.Text = "Send"
	$btn_1.BackColor = "WhiteSmoke"
	$btn_1.enabled = $False
	$btn_1.Add_Click({&$send_value})
	
	#Slider Panel
	$slider_panel = New-Object System.Windows.Forms.Panel
	$slider_panel.Location = "10,30"
	$slider_panel.Size = "330,95"
	$slider_panel.BackColor = "ButtonHighlight"
	$slider_panel.BorderStyle = "FixedSingle"
	$slider_panel.Visible = $False
	
	#No Limit Checkbox (Slider Panel)
	$no_lim_cbx = New-Object System.Windows.Forms.CheckBox
	$no_lim_cbx.Size = "15,22"
	$no_lim_cbx.Location = "15,15"
	$no_lim_cbx.Add_Click({&$disable_slider})
	
	$no_lim_lbl = New-Object System.Windows.Forms.Label
	$no_lim_lbl.Size = "60,20"
	$no_lim_lbl.Location = "35,15"
	$no_lim_lbl.Text = "No Limit"
	$no_lim_lbl.Font = "Microsoft Segoe UI,10,style=Bold"
	
	#NumericUpDown (Slider Panel)
	$nud_1 = New-Object System.Windows.Forms.NumericUpDown
	$nud_1.Size = "55,20"
	$nud_1.Location = "120,15"
	$nud_1.Maximum = 1000
	$nud_1.Minimum = 128
	$nud_1.Increment = 10
	$nud_1.Value = 128
	$nud_1.add_ValueChanged({&$nud_slider_value})
	
	#Slider Combo Box (Slider Panel)
	$cmb_2 = New-Object System.Windows.Forms.ComboBox
	$cmb_2.size = "60,20"
	$cmb_2.location = "175,15"
	@("kbps","Mbps") | %{$cmb_2.Items.Add($_)}
	$cmb_2.SelectedIndex = 0
	$cmb_2.add_SelectedIndexChanged({&$dtr_cmb_event})
	
	#Slider (Slider Panel)
	$slider = New-Object System.Windows.Forms.Trackbar
	$slider.Size = "220,50"
	$slider.Location = "15,50"
	$slider.TickStyle = "None"
	$slider.SetRange(16000,125000)
	$slider.Value = 16000
	$slider.add_ValueChanged({&$slider_nud_value})
	
	#Send Button (Slider Panel)
	$btn_2 = New-Object System.Windows.Forms.Button
	$btn_2.size = "75,30"
	$btn_2.location = "245,30"
	$btn_2.Text = "Send"
	$btn_2.BackColor = "WhiteSmoke"
	$btn_2.enabled = $False
	$btn_2.Add_Click({&$send_value})
	
	$message = {
		param([string] $m,[string] $l,[string] $s)
		$message_form = New-Object System.Windows.Forms.Form
		$message_form.size = "360,210"
		$message_form.text = "Network limiter"
		$message_form.StartPosition = "CenterScreen"
		$message_form.Add_Closing({&$closing_event_2})

		$message_lb = New-Object System.Windows.Forms.Label
		$message_lb.size = $s
		$message_lb.location = $l
		$message_lb.Font = "Microsoft Segoe UI,11.5,style=Bold"
		$message_lb.Text = $m
		$message_lb.TextAlign = "MiddleCenter"

		$mbtn_1 = New-Object System.Windows.Forms.Button
		$mbtn_1.size = "95,35"
		$mbtn_1.location = "120,110"
		$mbtn_1.Text = "Okay"
		$mbtn_1.Add_Click({$message_form.close()})
		
		$message_form.Controls.add($message_lb)
		$message_form.Controls.add($mbtn_1)
		
		$message_form.ShowDialog()
	}
	
	
	<#Custom Text Box (Custom Panel)
	$tbx_1 = New-Object System.Windows.Forms.Textbox
	$tbx_1.size = "80,20"
	$tbx_1.location = "40,60"#>
	
	#Device Info Panel
	$device_panel = New-Object System.Windows.Forms.Panel
	$device_panel.Location = "10,140"
	$device_panel.Size = "330,100"
	$device_panel.BackColor = "ControlLight"
	$device_panel.BorderStyle = "FixedSingle"
	$device_panel.Visible = $True
	$device_panel.Add_MouseEnter({&$check_process})
	
	#Device Label
	$lbl_1 = New-Object System.Windows.Forms.Label
	$lbl_1.TextAlign = "MiddleCenter"
	$lbl_1.Font = "Microsoft Segoe UI,10,style=Bold"
	$lbl_1.Text = "Device:"
	$lbl_1.location = "10,15"
	$lbl_1.Autosize = $True
	$lbl_1.Size = "70,30"
	
	#Device Text Box
	$tbx_2 = New-Object System.Windows.Forms.Textbox
	$tbx_2.size = "130,20"
	$tbx_2.location = "70,15"
	$tbx_2.Text = ""
	$tbx_2.ReadOnly = $True
	
	#Device Refresh
	$btn_refresh = New-Object System.Windows.Forms.Button
	$btn_refresh.size = "30,25"
	$btn_refresh.location = "210,15"
	$btn_refresh.Image = [System.Drawing.Image]::FromFile("$PWD/Static/Refresh_Icon_.png")
	$btn_refresh.Add_Click({.$adb_path kill-server;&$reset_comp;&$adb_linking})
	
	#Device Wireless Mode
	$btn_wireless = New-Object System.Windows.Forms.Button
	$btn_wireless.size = "30,25"
	$btn_wireless.location = "245,15"
	$btn_wireless.Image = [System.Drawing.Image]::FromFile("$PWD/Static/Wireless_Icon_.jpg")
	$btn_wireless.Enabled = $False
	$btn_wireless.Add_Click({&$wireless_connection})
	
	#Device Mirror Mode
	$btn_mirror = New-Object System.Windows.Forms.Button
	$btn_mirror.size = "30,25"
	$btn_mirror.location = "280,15"
	$btn_mirror.Image = [System.Drawing.Image]::FromFile("$PWD/Static/Mirror_Icon_.png")
	$btn_mirror.Enabled = $False
	$btn_mirror.Add_Click({&$mirror_device})
	
	#Status Label
	$lbl_2 = New-Object System.Windows.Forms.Label
	$lbl_2.TextAlign = "MiddleCenter"
	$lbl_2.Font = "Microsoft Segoe UI,10,style=Bold"
	$lbl_2.Text = "Status:"
	$lbl_2.location = "10,40"
	$lbl_2.Autosize = $True
	$lbl_2.Size = "70,30"
	
	#Status Text Box
	$tbx_3 = New-Object System.Windows.Forms.Textbox
	$tbx_3.size = "60,20"
	$tbx_3.location = "70,40"
	$tbx_3.Text = ""
	$tbx_3.ReadOnly = $True
	
	#IP Address Label
	$lbl_3 = New-Object System.Windows.Forms.Label
	$lbl_3.TextAlign = "MiddleCenter"
	$lbl_3.Font = "Microsoft Segoe UI,10,style=Bold"
	$lbl_3.Text = "IP Address:"
	$lbl_3.location = "10,70"
	$lbl_3.Autosize = $True
	$lbl_3.Size = "85,20"
	
	#IP Address Text Box
	$tbx_4 = New-Object System.Windows.Forms.Textbox
	$tbx_4.size = "95,65"
	$tbx_4.location = "95,70"
	$tbx_4.Text = ""
	$tbx_4.ReadOnly = $True
	
	# Events
	$closing_event_1 = {
		#Server Restart
		.$adb_path kill-server
		#Simple Panel Dispose
		@($simple_panel,$slider_panel,$device_panel)| %{$_.Dispose()}
	}
	$closing_event_2 = {
		@($message_lb, $mbtn_1) | %{$_.Dispose()}
	}
	$adb_linking = {
		$device.version = [int] $(.$adb_path shell getprop ro.build.version.release)
		write-host $device.version
		if($device.version -ge 13){
			&$wired_status
		}else{
			if($device.version -ne 0 ){
				&$message -m "Incompatible Device Please Upgrade To Android 13 To Proceed" -l "75,40" -s "180,60"
			}else{
				&$message -m "No Device Detected Please Connect A Device" -l "75,40" -s "180,60"
				@($btn_1,$btn_2) | %{$_.enabled = $false}
			}
		}
	}
	$wireless_connection = {
		#Test this with Global Protect
		try{
			#Check if device is connect to VPN
			if($(.$adb_path shell ip addr show tun0).length -eq 0){
				$device.ip_addr = $((.$adb_path shell ip addr show wlan0 | select-string 'inet\s\d+.\d+.\d+.\d+').matches.value).split(' ')[1]
			}else{
				$device.ip_addr = $((.$adb_path shell ip addr show tun0 | select-string 'inet\s\d+.\d+.\d+.\d+').matches.value).split(' ')[1]
			}
			.$adb_path tcpip 5555
			.$adb_path connect $device.ip_addr
			&$message -m "Please Disconnect The Device" -l "95,49" -s "145,40"
		}catch{
			continue
		}
		try{
			&$wireless_status
		}catch{
			&$message -m "An Error Has Occur Please Re-Connect A Device" -l "75,40" -s "180,60"
		}
		
	}
	$mirror_device = {
		Start -FilePath $scrcpy_path -NoNewWindow
		$btn_mirror.Enabled = $False
	}
	$check_process = {
		if((Get-Process).ProcessName.contains("scrcpy")){
			$btn_mirror.Enabled = $False
		}else{
			if($device.model.length -gt 0){
				$btn_mirror.Enabled = $True
			}else{$btn_mirror.Enabled = $False}
		}
	}
	$call_simple_panel = {
		$slider_panel.Visible = $False
		$simple_panel.Visible = $True
	}
	$call_slider_panel = {
		$simple_panel.Visible = $False
		$slider_panel.Visible = $True
	}
	$call_custom_panel = {
		
	}
	$dtr_cmb_event = {
		switch($cmb_2.SelectedIndex){
			0{
				$slider.SetRange(16000,125000)
				$nud_1.Maximum = 1000
				$nud_1.Minimum = 128
				$nud_1.Increment = 10
				$nud_1.DecimalPlaces = 0
				$slider.Value = $slider.Minimum
			}
			1{
				$slider.SetRange(125000,1875000)
				$nud_1.Maximum = 15
				$nud_1.Minimum = 1
				$nud_1.Increment = 0.25
				$nud_1.DecimalPlaces = 2
				$slider.Value = $slider.Minimum
			}
		}
	}
	$nud_slider_value = {
		switch($cmb_2.SelectedIndex){
			0{
				$slider.value = [Math]::Ceiling($nud_1.Value * 125)
			}
			1{
				$slider.value = ($nud_1.value * 125000)
			}
		
		}
	}
	$slider_nud_value = {
		switch($cmb_2.SelectedIndex){
			0{
				$nud_1.Value = [Math]::Floor($slider.value / 125)
			}
			1{
				$nud_1.Value = ($slider.value/125000)
			}
		}
	}
	$disable_slider = {
		if($no_lim_cbx.Checked){
			@($slider,$nud_1,$cmb_2) | %{$_.enabled = $False}
		}else{
			@($slider,$nud_1,$cmb_2) | %{$_.enabled = $True}
		}
	}
	$reset_comp = {
		$device.Clear()
		@($tbx_2,$tbx_3,$tbx_4) | %{$_.Text = ""}
		$btn_wireless.Enabled = $False; $btn_mirror.Enabled = $False
		@($btn_1,$btn_2) | %{$_.enabled = $True}
	}
	$wired_status = {
		try{
			#Check For Serial Number and Status
			$buffer = $(.$adb_path devices | select-string "([A-Za-z]+([0-9]+[A-Za-z]+)+)\s+[A-Za-z0-9]+").Matches.Value.Split('\s+')
			
		}catch{
			&$message -m "Something Went Wrong Please Try Again" -l "75,40" -s "180,60"
			continue
		}
		if($buffer.length -gt 0){
				$device.serial = $buffer[0]
				$device.auth = $buffer[1]
				if ($(.$adb_path shell settings get global default_device_name) -eq "null"){
					if($(.$adb_path shell settings get global device_name) -ne "null"){
						$device.model = .$adb_path shell settings get global device_name
					}else{
						$device.model = "Android Device"
					}
				}else{
					$device.model = .$adb_path shell settings get global default_device_name
				}
				$tbx_2.Text = $device.model
				$tbx_3.Text = "Connected"
				$btn_wireless.Enabled = $True
				$btn_mirror.Enabled = $True
				$btn_1.Enabled = $True;$btn_2.Enabled = $True
		}else{
			&$wireless_status
		}
	}
	$wireless_status = {
		#Test this with Global Protect, Reasearch this for loop issue
		
		$buffer = $(.$adb_path devices | select-string "([0-9]+(\.[0-9]+)+):\d+\s+[A-Za-z0-9]+").Matches.Value.replace('\s+',' ').split(':').split()
		if($buffer.length -gt 0){
			$device.ip_addr = $buffer[0]
			$device.port = $buffer[1]
			$device.auth = $buffer[2]
			if($device.auth -eq "device"){$device.auth = "Online"}
			$tbx_2.Text = $device.model
			$tbx_3.Text = $device.auth
			$tbx_4.Text = $device.ip_addr
			$btn_wireless.enabled = $False
			@($btn_1,$btn_2) | %{$_.enabled = $True}
		}else{
			$device.Clear()
		}
	}
	
	$send_value = {
		if($simple_panel.Visible -eq $True){
			switch($cmb_1.SelectedIndex){
				0{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second -1}
				1{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second 16000}
				2{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second 32000}
				3{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second 125000}
				4{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second 625000}
				5{.$adb_path shell settings put global ingress_rate_limit_bytes_per_second 1875000}
			}
		}elseif($slider_panel.Visible -eq $True){
			if($no_lim_cbx.checked){
				.$adb_path shell settings put global ingress_rate_limit_bytes_per_second -1
			}else{
				.$adb_path shell settings put global ingress_rate_limit_bytes_per_second $slider.Value
			}
		}
	}
	<#$panel_send_button = {
		if($simple_panel.Visible -eq $True){
			$btn_1.enabled = $True
		}else{
			$btn_1.enabled = $False
			if($slider_panel.Visible -eq $True){
				$btn_2.enabled = $True
			}else{
				$btn_2.enabled = $False
			}
		}
			
	}#>
	#Adding contents into Panel
	@($speed_lbl,$cmb_1,$btn_1)|%{$simple_panel.Controls.Add($_)}
	@($no_lim_cbx,$no_lim_lbl,$nud_1,$cmb_2,$slider,$btn_2)|%{$slider_panel.Controls.Add($_)}
	@($lbl_1,$tbx_2,$btn_refresh,$btn_wireless,$btn_mirror,$lbl_2,$tbx_3,$lbl_3,$tbx_4) | %{$device_panel.Controls.Add($_)}
	#Adding contents into Main Form
	@($main_strip,$simple_panel,$slider_panel,$device_panel) | `
	%{$main_form.Controls.add($_)}
	
	
	$main_form.ShowDialog()
}
&$GUI