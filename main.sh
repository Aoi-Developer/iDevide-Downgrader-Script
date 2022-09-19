#!/bin/sh
cd ~/Desktop
#ideviceinfoがインストールされているか確認します
which ideviceinfo >/dev/null 2>&1
if [ $? -ne 0 ] ; then
  #インストールされていない場合Homebrewがインストールされているか確認します
  which brew >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    #存在しない場合はインストールするようメッセージを出力して実行を停止します
    echo "E: Homebrewがインストールされていません。以下コマンドを実行して再試行してください"
    echo "bash <(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit 1
  else
    #Homebrewがあればlibimobiledeviceをインストールします
    brew install libimobiledevice
  fi
else
  echo "[OK]ideviceinfo"
fi
#ツール群をまとめるディレクトリを作成します
if [ -d otadown ]; then
  cd otadown
else
  mkdir otadown
  cd otadown
fi
#futurerestore2をダウンロードします
if [ -f futurerestore_2 ]; then
  echo "[OK]futurerestore_2"
else
  curl -OL https://dl.dropboxusercontent.com/s/pd0mwmh7q1d51iw/futurerestore
  mv futurerestore futurerestore_2
  chmod -R 766 futurerestore_2
fi
#futurerestore_libipatcherをダウンロードします
if [ -f futurerestore_3 ]; then
  echo "[OK]futurerestore_libipatcher"
else
  curl -OL https://dl.dropboxusercontent.com/s/c98y2emha4o3e9u/futurerestore_macos
  mv futurerestore_macos futurerestore_3
  chmod -R 766 futurerestore_3
fi
#futurerestoreをダウンロードします
if [ -f futurerestore ]; then
  echo "[OK]futurerestore"
else
  curl -OL https://github.com/tihmstar/futurerestore/releases/download/180/futurerestore_macOS_v180.zip
  unzip futurerestore_macOS_v180.zip
  rm futurerestore_macOS_v180.zip
fi
#tsscheckerをダウンロードします
if [ -f tsschecker ]; then
  echo "[OK]tsschecker"
else
  curl -OL https://github.com/tihmstar/tsschecker/releases/download/304/tsschecker_macOS_v304.zip
  unzip tsschecker_macOS_v304.zip
  rm tsschecker_macOS_v304.zip
fi
#ipwnder_liteを準備します
if [ -f ipwnder_macosx ]; then
  echo "[OK]ipwnder"
else
  git clone https://github.com/dora2-iOS/ipwnder_lite --recursive
  cd ipwnder_lite
  make
  mv ipwnder_macosx ../
  cd ../
  rm -rf ipwnder_lite
fi
#ipwnder32を準備します
if [ -f ipwnder32_x86_64 ]; then
  echo "[OK]iPwnder32"
else
  curl -OL https://github.com/dora2-iOS/iPwnder32/archive/refs/tags/3.1.zip
  unzip 3.1.zip
  rm 3.1.zip
  cd iPwnder32-3.1
  ./BUILD_x86_64
  mv ipwnder32_x86_64 ../ipwnder32_x86_64
  cd ../
  rm -rf iPwnder32-3.1
fi
#デバイス情報を読み取り作業用ディレクトリを作成します
ideviceinfo >/dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "iDeviceが接続されていません。"
  echo "MacにiPhoneを接続し信頼した後再試行してください"
  exit 1
fi
ecid=$(ideviceinfo | grep UniqueChipID | sed 's/UniqueChipID: //g')
model=$(ideviceinfo | grep ProductType | sed 's/ProductType: //g')
udid=$(idevice_id --list)
echo -n "ECID:"
echo $ecid
#モデル名のディレクトリを作成
if [ -d $model ]; then
  cd $model
else
  mkdir $model
  cd $model
fi
#ECID名のディレクトリを作成
if [ -d $ecid ]; then
  cd $ecid
else
  mkdir $ecid
  cd $ecid
fi

#iPhone4sの場合
if [ "iPhone4,1" = $model ]; then
  cd ../
  #BuildManifest_613があるか確認します
  if [ -f BuildManifest_iPhone4,1_613_OTA.plist ]; then
    echo "[OK]BuildManifest_613"
  else
    curl -OL https://raw.githubusercontent.com/Aoi-Developer/iDevide-Downgrader-Script/main/Manfiest/BuildManifest_iPhone4,1_613_OTA.plist
  fi
  #BuildManifest_814があるか確認します
  if [ -f BuildManifest_iPhone4,1_841_OTA.plist ]; then
    echo "[OK]BuildManifest_814"
  else
    curl -OL https://raw.githubusercontent.com/Aoi-Developer/iDevide-Downgrader-Script/main/Manfiest/BuildManifest_iPhone4,1_841_OTA.plist
  fi
  #814のSHSHがあるか確認します
  cd $ecid
  ls -1 `echo $model`_`echo $ecid`_841.shsh2 >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    mkdir 841
    cd 841
    ../../.././tsschecker -d $model -e $ecid -m ../../BuildManifest_iPhone4,1_841_OTA.plist -s  
    mv `ls -1 | grep shsh2` ../`echo $model`_`echo $ecid`_841.shsh2
    cd ../
    rm -rf 841
  else
    echo "[OK]SHSH_841"
  fi
  #613のSHSHがあるか確認します
  ls -1 `echo $model`_`echo $ecid`_613.shsh2 >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    mkdir 613
    cd 613
    ../../.././tsschecker -d $model -e $ecid -m ../../BuildManifest_iPhone4,1_613_OTA.plist -s  
    mv `ls -1 | grep shsh2` ../`echo $model`_`echo $ecid`_613.shsh2
    cd ../
    rm -rf 613
  else
    echo "[OK]SHSH_613"
  fi
  cd ../
  echo 
  echo "※現状iPhone4sではJailbreakであり、kDFUAppがインストールされている必要があります"
  echo "接続されているデバイスには複数のダウングレード可能なバージョンが存在します。"
  echo "ダウングレードしたいバーションを番号で選択し、Enterをおしてください"
  echo "1 :)ios6.1.3"
  echo "2 :)ios8.4.1"
  echo -n "番号:"
  read ANS
  if [ 1 = $ANS ] ; then
    echo "ios6.1.3に復元されます"
    if [ -f iPhone4,1_6.1.3_10B329_Restore.ipsw ]; then
      echo "[OK]IPSW"
    else
      curl -OL http://appldnld.apple.com/iOS6.1/091-2611.20130319.Fr54r/iPhone4,1_6.1.3_10B329_Restore.ipsw
    fi
    if [ -f Firmware/Trek-3.4.03.Release.bbfw ]; then
      echo "[OK]bbfw"
    else
      unzip iPhone4,1_6.1.3_10B329_Restore.ipsw Firmware/Trek-3.4.03.Release.bbfw
    fi
    echo "kDFUAppを使用して端末をPwndfu Modeにしてください"
    echo -n "Pwndfu Modeにできたら[Y]を押してください[Y/n]:"
    read ANS
    case $ANS in
      "" | [Yy]* )
        echo 
        ;;
      * )
        echo "ダウングレードをキャンセルしました"
        exit
        ;;
      esac
    .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_613.shsh2 -b Firmware/Trek-3.4.03.Release.bbfw -p BuildManifest_iPhone4,1_613_OTA.plist -m BuildManifest_iPhone4,1_613_OTA.plist --use-pwndfu iPhone4,1_6.1.3_10B329_Restore.ipsw
    sleep 5
    .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_613.shsh2 -b Firmware/Trek-3.4.03.Release.bbfw -p BuildManifest_iPhone4,1_613_OTA.plist -m BuildManifest_iPhone4,1_613_OTA.plist --use-pwndfu iPhone4,1_6.1.3_10B329_Restore.ipsw
    echo .
    echo "スクリプトの実行が終了しました。ダウングレードに失敗した場合はPwndfuモードにした後、以下コマンドを実行すると再実行できます"
    echo "cd `pwd` && .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_613.shsh2 -b Firmware/Trek-3.4.03.Release.bbfw -p BuildManifest_iPhone4,1_841_OTA.plist -m BuildManifest_iPhone4,1_841_OTA.plist --use-pwndfu iPhone4,1_6.1.3_10B329_Restore.ipsw"
    exit
  elif [ 2 = $ANS ] ; then
    echo "ios8.4.1に復元されます"
    if [ -f iPhone4,1_8.4.1_12H321_Restore.ipsw ]; then
      echo "[OK]IPSW"
    else
      curl -OL http://appldnld.apple.com/ios8.4.1/031-31129-20150812-751A3CB8-3C8F-11E5-A8A5-A91A3A53DB92/iPhone4,1_8.4.1_12H321_Restore.ipsw
    fi
    if [ -f Firmware/Trek-5.5.00.Release.bbfw ]; then
      echo "[OK]bbfw"
    else
      unzip iPhone4,1_8.4.1_12H321_Restore.ipsw Firmware/Trek-5.5.00.Release.bbfw
    fi
    echo "kDFUAppを使用して端末をPwndfu Modeにしてください"
    echo -n "Pwndfu Modeにできたら[Y]を押してください[Y/n]:"
    read ANS
    case $ANS in
      "" | [Yy]* )
        echo 
        ;;
      * )
        echo "ダウングレードをキャンセルしました"
        exit
        ;;
      esac
    .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_841.shsh2 -b Firmware/Trek-5.5.00.Release.bbfw -p BuildManifest_iPhone4,1_841_OTA.plist -m BuildManifest_iPhone4,1_841_OTA.plist --use-pwndfu iPhone4,1_8.4.1_12H321_Restore.ipsw 
    sleep 5
    .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_841.shsh2 -b Firmware/Trek-5.5.00.Release.bbfw -p BuildManifest_iPhone4,1_841_OTA.plist -m BuildManifest_iPhone4,1_841_OTA.plist --use-pwndfu iPhone4,1_8.4.1_12H321_Restore.ipsw 
    echo .
    echo "スクリプトの実行が終了しました。ダウングレードに失敗した場合はPwndfuモードにした後、以下コマンドを実行すると再実行できます"
    echo "cd `pwd` && .././futurerestore_3 -t $ecid/`echo $model`_`echo $ecid`_841.shsh2 -b Firmware/Trek-5.5.00.Release.bbfw -p BuildManifest_iPhone4,1_841_OTA.plist -m BuildManifest_iPhone4,1_841_OTA.plist --use-pwndfu iPhone4,1_8.4.1_12H321_Restore.ipsw"
    exit
  else
    echo "無効な数値が入力されました。初めからやり直してください"
    exit 1
  fi
  exit
fi

#iPhone5の場合
if [ "iPhone5,2" = $model ]; then
  echo "接続されているiPhone5は[ios8.4.1]にダウングレードされます"
  cd ../
  if [ -f BuildManifest_iPhone5,2_841_OTA.plist ]; then
    echo "[OK]BuildManifest"
  else
    curl -OL https://raw.githubusercontent.com/Aoi-Developer/iDevide-Downgrader-Script/main/Manfiest/BuildManifest_iPhone5,2_841_OTA.plist
  fi
  cd $ecid
  ls -1 `echo $model`_`echo $ecid`.shsh2 >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    ../.././tsschecker -d $model -e $ecid -m ../BuildManifest_iPhone5,2_841_OTA.plist -s  
    mv `ls -1 | grep shsh2` `echo $model`_`echo $ecid`.shsh2
  else
    echo "[OK]SHSH"
  fi
  cd ../
  if [ -f iPhone5,2_8.4.1_12H321_Restore.ipsw ]; then
    echo "[OK]IPSW"
  else
    curl -OL http://appldnld.apple.com/ios8.4.1/031-31065-20150812-7518F132-3C8F-11E5-A96A-A11A3A53DB92/iPhone5,2_8.4.1_12H321_Restore.ipsw
  fi
  if [ -f Firmware/Mav5-8.02.00.Release.bbfw ]; then
    echo "[OK]bbfw"
  else
    unzip iPhone5,2_8.4.1_12H321_Restore.ipsw Firmware/Mav5-8.02.00.Release.bbfw
  fi
  echo -n "ダウングレードの準備ができました。[Y]を押すと続行します。[Y/n]:"
  read ANS
  case $ANS in
    "" | [Yy]* )
      echo "電源とホームボタンを長押ししてiPhoneをDFUモードにしてください。"
      ;;
    * )
      echo "ダウングレードをキャンセルしました"
      exit
      ;;
    esac
  .././ipwnder32_x86_64 -p
  .././ipwnder32_x86_64 -p
  .././futurerestore_2 -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav5-8.02.00.Release.bbfw -p BuildManifest_iPhone5,2_841_OTA.plist -m BuildManifest_iPhone5,2_841_OTA.plist --use-pwndfu iPhone5,2_8.4.1_12H321_Restore.ipsw
  sleep 5
  .././futurerestore_2 -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav5-8.02.00.Release.bbfw -p BuildManifest_iPhone5,2_841_OTA.plist -m BuildManifest_iPhone5,2_841_OTA.plist --use-pwndfu iPhone5,2_8.4.1_12H321_Restore.ipsw
  echo .
  echo "スクリプトの実行が終了しました。ダウングレードに失敗した場合はDFUモードにした後、以下コマンドを実行すると再実行できます"
  echo "cd `pwd` && .././ipwnder_macosx && .././futurerestore_2 -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav5-8.02.00.Release.bbfw -p BuildManifest_iPhone5,2_841_OTA.plist -m BuildManifest_iPhone5,2_841_OTA.plist --use-pwndfu iPhone5,2_8.4.1_12H321_Restore.ipsw"
  exit
fi


#iPhone5sの場合
if [ "iPhone6,1" = $model ]; then
  echo "接続されているiPhone5sは[ios10.3.3]にダウングレードされます"
  cd ../
  if [ -f BuildManifest_iPhone6,1_1033_OTA.plist ]; then
    echo "[OK]BuildManifest"
  else
    curl -OL https://raw.githubusercontent.com/Aoi-Developer/iDevide-Downgrader-Script/main/Manfiest/BuildManifest_iPhone6,1_1033_OTA.plist
  fi
  cd $ecid  
  ls -1 `echo $model`_`echo $ecid`.shsh2 >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    ../.././tsschecker -d $model -e $ecid -m ../BuildManifest_iPhone6,1_1033_OTA.plist -s
    mv `ls -1 | grep shsh2` `echo $model`_`echo $ecid`.shsh2
  else                  
    echo "[OK]SHSH"                                      
  fi                                                        
  cd ../ 
  if [ -f iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw ]; then
    echo "[OK]IPSW"
  else
    curl -OL http://appldnld.apple.com/ios10.3.3/091-23133-20170719-CA8E78E6-6977-11E7-968B-2B9100BA0AE3/iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw
  fi
  if [ -f Firmware/Mav7Mav8-7.60.00.Release.bbfw ]; then
    echo "[OK]bbfw"
  else
    unzip iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw Firmware/Mav7Mav8-7.60.00.Release.bbfw
  fi
  if [ -f Firmware/all_flash/sep-firmware.n51.RELEASE.im4p ]; then
    echo "[OK]SEP"
  else
    unzip iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw Firmware/all_flash/sep-firmware.n51.RELEASE.im4p
  fi
  echo -n "ダウングレードの準備ができました。[Y]を押すと続行します。[Y/n]:"
  read ANS
  case $ANS in
    "" | [Yy]* )
      echo "電源とホームボタンを長押ししてiPhoneをDFUモードにしてください。"
      ;;
    * )
      echo "ダウングレードをキャンセルしました"
      exit
      ;;
    esac
  .././ipwnder_macosx
  if [ $? -ne 0 ] ; then
    echo "Powndfuにできませんでした。スクリプトを再試行してください"
    exit 1
  else
    echo "[OK]Powndfu"
  fi
  .././futurerestore -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav7Mav8-7.60.00.Release.bbfw -s Firmware/all_flash/sep-firmware.n51.RELEASE.im4p -p BuildManifest_iPhone6,1_1033_OTA.plist -m BuildManifest_iPhone6,1_1033_OTA.plist --use-pwndfu iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw
  sleep 5
  .././futurerestore -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav7Mav8-7.60.00.Release.bbfw -s Firmware/all_flash/sep-firmware.n51.RELEASE.im4p -p BuildManifest_iPhone6,1_1033_OTA.plist -m BuildManifest_iPhone6,1_1033_OTA.plist --use-pwndfu iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw
  echo .
  echo "スクリプトの実行が終了しました。ダウングレードに失敗した場合はDFUモードにした後、以下コマンドを実行すると再実行できます"
  echo "cd `pwd` && .././ipwnder_macosx && .././futurerestore -t $ecid/`echo $model`_`echo $ecid`.shsh2 -b Firmware/Mav7Mav8-7.60.00.Release.bbfw -s Firmware/all_flash/sep-firmware.n51.RELEASE.im4p -p BuildManifest_iPhone6,1_1033_OTA.plist -m BuildManifest_iPhone6,1_1033_OTA.plist --use-pwndfu iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw"
  exit
fi

echo "この端末はこのスクリプトでダウングレードできません"
exit 1

