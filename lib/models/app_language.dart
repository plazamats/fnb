enum AppLanguage {
  english('en', 'English'),
  isizulu('zu', 'isiZulu'),
  sesotho('st', 'Sesotho'),
  siswati('ss', 'siSwati'),
  isixhosa('xh', 'isiXhosa'),
  afrikaans('af', 'Afrikaans');

  const AppLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  String get greeting => switch (this) {
    AppLanguage.isizulu => 'Sawubona, Mninisitolo',
    AppLanguage.sesotho => 'Dumela, Mong wa lebenkele',
    AppLanguage.siswati => 'Sawubona, Mnikatolo',
    AppLanguage.isixhosa => 'Molo, Mnini-venkile',
    AppLanguage.afrikaans => 'Goeiedag, Winkeleienaar',
    AppLanguage.english => 'Hello, Shop Owner',
  };

  String get holdToSpeak => switch (this) {
    AppLanguage.isizulu => 'Bamba ukhulume (Ukuthengisa / Izindleko)',
    AppLanguage.sesotho => 'Tshwara o bue (Thekiso / Ditshenyehelo)',
    AppLanguage.siswati => 'Bamba ukhulume (Kutsengisa / Tindleko)',
    AppLanguage.isixhosa => 'Bamba uthethe (Ukuthengisa / Iindleko)',
    AppLanguage.afrikaans => 'Hou in om te praat (Verkope / Uitgawes)',
    AppLanguage.english => 'Hold to speak (Sales / Expenses / Stock)',
  };

  String get listening => switch (this) {
    AppLanguage.isizulu => 'Kuyalalela... Dedela uma uqedile',
    AppLanguage.sesotho => 'E ntse e mametse... Lokolla ha o qetile',
    AppLanguage.siswati => 'Kuyalalela... Khulula nawucedzile',
    AppLanguage.isixhosa => 'Iyamamela... Khulula xa ugqibile',
    AppLanguage.afrikaans => 'Luister tans... Laat los as jy klaar is',
    AppLanguage.english => 'Listening... Release when done',
  };

  String adviceForPeriod(String periodKey, {
    required double shopCosts,
    required double familyCosts,
    required double savings,
    required double takeHome,
  }) {
    final formattedProfit = 'R ${takeHome.toStringAsFixed(2)}';
    switch (periodKey) {
      case 'sassa':
        return switch (this) {
          AppLanguage.isizulu => 'Ngesikhathi se-SASSA, amakhasimende athenga kakhulu izinto eziyisisekelo. Inzuzo yakho ingu-$formattedProfit. Qiniseka ukuthi ugcina imali yokonga yomndeni eceleni.',
          AppLanguage.sesotho => 'Nakong ya SASSA, bareki ba reka dijo tsa motheo haholo. Phaello ya hao ke $formattedProfit. Boloka tjhelete ya lelapa le poloko ka thoko.',
          AppLanguage.siswati => 'Ngesikhatsi se-SASSA, batsengi batsenga kakhulu kudla lokubalulekile. Inzuzo yakho ngu-$formattedProfit. Gcina imali yekonga yendlu eceleni.',
          AppLanguage.isixhosa => 'Ngelixesha le-SASSA, abathengi bathenga ukutya okubalulekileyo. Ingeniso yakho yi-$formattedProfit. Gcina imali yokonga yosapho bucala.',
          AppLanguage.afrikaans => 'Gedurende die SASSA-periode koop kliënte noodsaaklikhede. Jou wins is $formattedProfit. Hou spaargeld en familiekoste veilig eenkant.',
          AppLanguage.english => 'During the SASSA grant period, basic essentials move fastest. Your current take-home profit is $formattedProfit. Keep family reserves and business cash separate.',
        };
      case 'mid_month':
        return switch (this) {
          AppLanguage.isizulu => 'Phakathi nenyanga, gcina ukuhamba kwemali kuqinile. Gwema ukuthenga isitoko esingadingeki ungakayi empeleni yenyanga.',
          AppLanguage.sesotho => 'Hare ho kgwedi, boloka tjhelete e tsitsitse. Qoba ho reka thepa e sa hlokahaleng ha jwale.',
          AppLanguage.siswati => 'Emkhatsini wenyanga, gcina imali icashekile. Gwema kutsenga sitoko lesingadzingeki kute kube sekupheleni kwenyanga.',
          AppLanguage.isixhosa => 'Phakathi nenyanga, gcina ukuhamba kwemali kuzinzile. Kuphephe ukuthenga impahla engabalulekanga ngoku.',
          AppLanguage.afrikaans => 'Middel-maand, hou jou kontantvloei bestendig. Vermy onnodige voorraadaankope en bewaar jou kontant.',
          AppLanguage.english => 'Mid-month, keep cash flow steady. Avoid buying extra stock unnecessarily and preserve your available cash.',
        };
      case 'payday':
        return switch (this) {
          AppLanguage.isizulu => 'Usuku lomholo lufikile (Usuku lwama-25)! Uma ikheshi livuma, gcwalisa iziphuzo ezibandayo nesinkwa ngaphambi kukaMgqibelo.',
          AppLanguage.sesotho => 'Letsatsi la moputso le fihlile (La 25)! Ha tjhelete e lumela, tlatsa dino tse batang le bohobe pele ho Moqebelo.',
          AppLanguage.siswati => 'Lilanga lemholo selifikile (Lama-25)! Nangabe imali ikhona, gcwalisa tinzuzo netiphuzo letibandzayo ngembikwaMgcibelo.',
          AppLanguage.isixhosa => 'Usuku lomvuzo lufikile (Umhla wama-25)! Ukuba imali ikhona, thenga iziselo ezibandayo nesonka phambi koMgqibelo.',
          AppLanguage.afrikaans => 'Betaaldag is hier (die 25ste)! Vul koeldrank en brood aan voor Saterdag indien bekostigbaar.',
          AppLanguage.english => 'Payday is here! Consider topping up cold drinks and bread before Saturday based on verified cash reserves.',
        };
      case 'month_end':
      default:
        return switch (this) {
          AppLanguage.isizulu => 'Isiphetho senyanga: Qathanisa izaphulelo ze-combo kubathengisi abakhulu (wholesalers) ukuze wonge kunsipho nasezintweni zokuhlanza.',
          AppLanguage.sesotho => 'Qetellong ya kgwedi: Bapisa ditheko tsa combo ho bo-wholesaler ho boloka tjhelete ho sesepa le tsa ho hlwekisa.',
          AppLanguage.siswati => 'Kuphela kwenyanga: Catsanisa tivumelwano te-combo te-wholesaler kute wonge kunsipho netinsita tekuhlanteka.',
          AppLanguage.isixhosa => 'Ekupheleni kwenyanga: Thelekisa izivumelwano ze-combo kwii-wholesalers ukuze wonge kwisepha nezicoci.',
          AppLanguage.afrikaans => 'Maandeinde: Vergelyk groothandel-kombinasie-aanbiedinge om op seep en skoonmaakmiddels te spaar.',
          AppLanguage.english => 'Time to restock? Compare wholesaler combo deals to save on soap and cleaning products before month-end rushes.',
        };
    }
  }
}
