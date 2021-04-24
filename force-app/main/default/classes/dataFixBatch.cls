global class dataFixBatch implements SandboxPostCopy  {


    global void runApexClass(SandboxContext context) { 
        sendSingleEmail('michal.zienkowski@britenet.com.pl', 'Org ' + [Select Name From Organization o][0].Name + ' odświeżył się, klasa ' + String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')) + ' została odpalona', 'Wszystko spoko');
    }
    
   private void sendSingleEmail (String emailAddress, String subject, String body) {
        List<String> address = new List<String>();
        address.add(emailAddress);
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setToAddresses (address);
        singleEmail.setHtmlBody(body);
        singleEmail.setSubject(subject);
        singleEmail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmail} );
    }
    
    /*Temporary method only for tests*/
    public static Integer testDebug(){
        Integer a = 0;
        if(true){
            a = 1;
        }
        if(true){
            a = 2;
        }
        if(true){
            a = 3;
        }
        if(true){
            a = 4;
        }
        if(true){
            a = 5;
        }
        if(true){
            a = 6;
        }
        if(true){
            a = 7;
        }
        if(true){
            a = 8;
        }
        if(true){
            a = 9;
        }
        if(true){
            a = 10;
        }
        if(true){
            a = 11;
        }
        if(true){
            a = 12;
        }
        if(true){
            a = 13;
        }
        if(true){
            a = 14;
        }
        if(true){
            a = 15;
        }
        if(true){
            a = 16;
        }
        if(true){
            a = 17;
        }
        if(true){
            a = 18;
        }
        if(true){
            a = 19;
        }
        if(true){
            a = 20;
        }
        if(true){
            a = 21;
        }
        if(true){
            a = 22;
        }
        if(true){
            a = 23;
        }
        if(true){
            a = 24;
        }
        if(true){
            a = 25;
        }
        if(true){
            a = 26;
        }
        if(true){
            a = 27;
        }
        if(true){
            a = 28;
        }
        if(true){
            a = 29;
        }
        if(true){
            a = 30;
        }
        if(true){
            a = 31;
        }
        if(true){
            a = 32;
        }
        if(true){
            a = 33;
        }
        if(true){
            a = 34;
        }
        if(true){
            a = 35;
        }
        if(true){
            a = 36;
        }
        if(true){
            a = 37;
        }
        if(true){
            a = 38;
        }
        if(true){
            a = 39;
        }
        if(true){
            a = 40;
        }
        if(true){
            a = 41;
        }
        if(true){
            a = 42;
        }
        if(true){
            a = 43;
        }
        if(true){
            a = 44;
        }
        if(true){
            a = 45;
        }
        if(true){
            a = 46;
        }
        if(true){
            a = 47;
        }
        if(true){
            a = 48;
        }
        if(true){
            a = 49;
        }
        if(true){
            a = 50;
        }
        if(true){
            a = 51;
        }
        if(true){
            a = 52;
        }
        if(true){
            a = 53;
        }
        if(true){
            a = 54;
        }
        if(true){
            a = 55;
        }
        if(true){
            a = 56;
        }
        if(true){
            a = 57;
        }
        if(true){
            a = 58;
        }
        if(true){
            a = 59;
        }
        if(true){
            a = 60;
        }
        if(true){
            a = 61;
        }
        if(true){
            a = 62;
        }
        if(true){
            a = 63;
        }
        if(true){
            a = 64;
        }
        if(true){
            a = 65;
        }
        if(true){
            a = 66;
        }
        if(true){
            a = 67;
        }
        if(true){
            a = 68;
        }
        if(true){
            a = 69;
        }
        if(true){
            a = 70;
        }
        if(true){
            a = 71;
        }
        if(true){
            a = 72;
        }
        if(true){
            a = 73;
        }
        if(true){
            a = 74;
        }
        if(true){
            a = 75;
        }
        if(true){
            a = 76;
        }
        if(true){
            a = 77;
        }
        if(true){
            a = 78;
        }
        if(true){
            a = 79;
        }
        if(true){
            a = 80;
        }
        if(true){
            a = 81;
        }
        if(true){
            a = 82;
        }
        if(true){
            a = 83;
        }
        if(true){
            a = 84;
        }
        if(true){
            a = 85;
        }
        if(true){
            a = 86;
        }
        if(true){
            a = 87;
        }
        if(true){
            a = 88;
        }
        if(true){
            a = 89;
        }
        if(true){
            a = 90;
        }
        if(true){
            a = 91;
        }
        if(true){
            a = 92;
        }
        if(true){
            a = 93;
        }
        if(true){
            a = 94;
        }
        if(true){
            a = 95;
        }
        if(true){
            a = 96;
        }
        if(true){
            a = 97;
        }
        if(true){
            a = 98;
        }
        if(true){
            a = 99;
        }
        if(true){
            a = 100;
        }
        if(true){
            a = 101;
        }
        if(true){
            a = 102;
        }
        if(true){
            a = 103;
        }
        if(true){
            a = 104;
        }
        if(true){
            a = 105;
        }
        if(true){
            a = 106;
        }
        if(true){
            a = 107;
        }
        if(true){
            a = 108;
        }
        if(true){
            a = 109;
        }
        if(true){
            a = 110;
        }
        if(true){
            a = 111;
        }
        if(true){
            a = 112;
        }
        if(true){
            a = 113;
        }
        if(true){
            a = 114;
        }
        if(true){
            a = 115;
        }
        if(true){
            a = 116;
        }
        if(true){
            a = 117;
        }
        if(true){
            a = 118;
        }
        if(true){
            a = 119;
        }
        if(true){
            a = 120;
        }
        if(true){
            a = 121;
        }
        if(true){
            a = 122;
        }
        if(true){
            a = 123;
        }
        if(true){
            a = 124;
        }
        if(true){
            a = 125;
        }
        if(true){
            a = 126;
        }
        if(true){
            a = 127;
        }
        if(true){
            a = 128;
        }
        if(true){
            a = 129;
        }
        if(true){
            a = 130;
        }
        if(true){
            a = 131;
        }
        if(true){
            a = 132;
        }
        if(true){
            a = 133;
        }
        if(true){
            a = 134;
        }
        if(true){
            a = 135;
        }
        if(true){
            a = 136;
        }
        if(true){
            a = 137;
        }
        if(true){
            a = 138;
        }
        if(true){
            a = 139;
        }
        if(true){
            a = 140;
        }
        if(true){
            a = 141;
        }
        if(true){
            a = 142;
        }
        if(true){
            a = 143;
        }
        if(true){
            a = 144;
        }
        if(true){
            a = 145;
        }
        if(true){
            a = 146;
        }
        if(true){
            a = 147;
        }
        if(true){
            a = 148;
        }
        if(true){
            a = 149;
        }
        if(true){
            a = 150;
        }
        if(true){
            a = 151;
        }
        if(true){
            a = 152;
        }
        if(true){
            a = 153;
        }
        if(true){
            a = 154;
        }
        if(true){
            a = 155;
        }
        if(true){
            a = 156;
        }
        if(true){
            a = 157;
        }
        if(true){
            a = 158;
        }
        if(true){
            a = 159;
        }
        if(true){
            a = 160;
        }
        if(true){
            a = 161;
        }
        if(true){
            a = 162;
        }
        if(true){
            a = 163;
        }
        if(true){
            a = 164;
        }
        if(true){
            a = 165;
        }
        if(true){
            a = 166;
        }
        if(true){
            a = 167;
        }
        if(true){
            a = 168;
        }
        if(true){
            a = 169;
        }
        if(true){
            a = 170;
        }
        if(true){
            a = 171;
        }
        if(true){
            a = 172;
        }
        if(true){
            a = 173;
        }
        if(true){
            a = 174;
        }
        if(true){
            a = 175;
        }
        if(true){
            a = 176;
        }
        if(true){
            a = 177;
        }
        if(true){
            a = 178;
        }
        if(true){
            a = 179;
        }
        if(true){
            a = 180;
        }
        if(true){
            a = 181;
        }
        if(true){
            a = 182;
        }
        if(true){
            a = 183;
        }
        if(true){
            a = 184;
        }
        if(true){
            a = 185;
        }
        if(true){
            a = 186;
        }
        if(true){
            a = 187;
        }
        if(true){
            a = 188;
        }
        if(true){
            a = 189;
        }
        if(true){
            a = 190;
        }
        if(true){
            a = 191;
        }
        if(true){
            a = 192;
        }
        if(true){
            a = 193;
        }
        if(true){
            a = 194;
        }
        if(true){
            a = 195;
        }
        if(true){
            a = 196;
        }
        if(true){
            a = 197;
        }
        if(true){
            a = 198;
        }
        if(true){
            a = 199;
        }
        if(true){
            a = 200;
        }
        if(true){
            a = 201;
        }
        if(true){
            a = 202;
        }
        if(true){
            a = 203;
        }
        if(true){
            a = 204;
        }
        if(true){
            a = 205;
        }
        if(true){
            a = 206;
        }
        if(true){
            a = 207;
        }
        if(true){
            a = 208;
        }
        if(true){
            a = 209;
        }
        if(true){
            a = 210;
        }
        if(true){
            a = 211;
        }
        if(true){
            a = 212;
        }
        if(true){
            a = 213;
        }
        if(true){
            a = 214;
        }
        if(true){
            a = 215;
        }
        if(true){
            a = 216;
        }
        if(true){
            a = 217;
        }
        if(true){
            a = 218;
        }
        if(true){
            a = 219;
        }
        if(true){
            a = 220;
        }
        if(true){
            a = 221;
        }
        if(true){
            a = 222;
        }
        if(true){
            a = 223;
        }
        if(true){
            a = 224;
        }
        if(true){
            a = 225;
        }
        if(true){
            a = 226;
        }
        if(true){
            a = 227;
        }
        if(true){
            a = 228;
        }
        if(true){
            a = 229;
        }
        if(true){
            a = 230;
        }
        if(true){
            a = 231;
        }
        if(true){
            a = 232;
        }
        if(true){
            a = 233;
        }
        if(true){
            a = 234;
        }
        if(true){
            a = 235;
        }
        if(true){
            a = 236;
        }
        if(true){
            a = 237;
        }
        if(true){
            a = 238;
        }
        if(true){
            a = 239;
        }
        if(true){
            a = 240;
        }
        if(true){
            a = 241;
        }
        if(true){
            a = 242;
        }
        if(true){
            a = 243;
        }
        if(true){
            a = 244;
        }
        if(true){
            a = 245;
        }
        if(true){
            a = 246;
        }
        if(true){
            a = 247;
        }
        if(true){
            a = 248;
        }
        if(true){
            a = 249;
        }
        if(true){
            a = 250;
        }
        if(true){
            a = 251;
        }
        if(true){
            a = 252;
        }
        if(true){
            a = 253;
        }
        if(true){
            a = 254;
        }
        if(true){
            a = 255;
        }
        if(true){
            a = 256;
        }
        if(true){
            a = 257;
        }
        if(true){
            a = 258;
        }
        if(true){
            a = 259;
        }
        if(true){
            a = 260;
        }
        if(true){
            a = 261;
        }
        if(true){
            a = 262;
        }
        if(true){
            a = 263;
        }
        if(true){
            a = 264;
        }
        if(true){
            a = 265;
        }
        if(true){
            a = 266;
        }
        if(true){
            a = 267;
        }
        if(true){
            a = 268;
        }
        if(true){
            a = 269;
        }
        if(true){
            a = 270;
        }
        if(true){
            a = 271;
        }
        if(true){
            a = 272;
        }
        if(true){
            a = 273;
        }
        if(true){
            a = 274;
        }
        if(true){
            a = 275;
        }
        if(true){
            a = 276;
        }
        if(true){
            a = 277;
        }
        if(true){
            a = 278;
        }
        if(true){
            a = 279;
        }
        if(true){
            a = 280;
        }
        if(true){
            a = 281;
        }
        if(true){
            a = 282;
        }
        if(true){
            a = 283;
        }
        if(true){
            a = 284;
        }
        if(true){
            a = 285;
        }
        if(true){
            a = 286;
        }
        if(true){
            a = 287;
        }
        if(true){
            a = 288;
        }
        if(true){
            a = 289;
        }
        if(true){
            a = 290;
        }
        if(true){
            a = 291;
        }
        if(true){
            a = 292;
        }
        if(true){
            a = 293;
        }
        if(true){
            a = 294;
        }
        if(true){
            a = 295;
        }
        if(true){
            a = 296;
        }
        if(true){
            a = 297;
        }
        if(true){
            a = 298;
        }
        if(true){
            a = 299;
        }
        if(true){
            a = 300;
        }
        if(true){
            a = 301;
        }
        if(true){
            a = 302;
        }
        if(true){
            a = 303;
        }
        if(true){
            a = 304;
        }
        if(true){
            a = 305;
        }
        if(true){
            a = 306;
        }
        if(true){
            a = 307;
        }
        if(true){
            a = 308;
        }
        if(true){
            a = 309;
        }
        if(true){
            a = 310;
        }
        if(true){
            a = 311;
        }
        if(true){
            a = 312;
        }
        if(true){
            a = 313;
        }
        if(true){
            a = 314;
        }
        if(true){
            a = 315;
        }
        if(true){
            a = 316;
        }
        if(true){
            a = 317;
        }
        if(true){
            a = 318;
        }
        if(true){
            a = 319;
        }
        if(true){
            a = 320;
        }
        if(true){
            a = 321;
        }
        if(true){
            a = 322;
        }
        if(true){
            a = 323;
        }
        if(true){
            a = 324;
        }
        if(true){
            a = 325;
        }
        if(true){
            a = 326;
        }
        if(true){
            a = 327;
        }
        if(true){
            a = 328;
        }
        if(true){
            a = 329;
        }
        if(true){
            a = 330;
        }
        if(true){
            a = 331;
        }
        if(true){
            a = 332;
        }
        if(true){
            a = 333;
        }
        if(true){
            a = 334;
        }
        if(true){
            a = 335;
        }
        if(true){
            a = 336;
        }
        if(true){
            a = 337;
        }
        if(true){
            a = 338;
        }
        if(true){
            a = 339;
        }
        if(true){
            a = 340;
        }
        if(true){
            a = 341;
        }
        if(true){
            a = 342;
        }
        if(true){
            a = 343;
        }
        if(true){
            a = 344;
        }
        if(true){
            a = 345;
        }
        if(true){
            a = 346;
        }
        if(true){
            a = 347;
        }
        if(true){
            a = 348;
        }
        if(true){
            a = 349;
        }
        if(true){
            a = 350;
        }
        if(true){
            a = 351;
        }
        if(true){
            a = 352;
        }
        if(true){
            a = 353;
        }
        if(true){
            a = 354;
        }
        if(true){
            a = 355;
        }
        if(true){
            a = 356;
        }
        if(true){
            a = 357;
        }
        if(true){
            a = 358;
        }
        if(true){
            a = 359;
        }
        if(true){
            a = 360;
        }
        if(true){
            a = 361;
        }
        if(true){
            a = 362;
        }
        if(true){
            a = 363;
        }
        if(true){
            a = 364;
        }
        if(true){
            a = 365;
        }
        if(true){
            a = 366;
        }
        if(true){
            a = 367;
        }
        if(true){
            a = 368;
        }
        if(true){
            a = 369;
        }
        if(true){
            a = 370;
        }
        if(true){
            a = 371;
        }
        if(true){
            a = 372;
        }
        if(true){
            a = 373;
        }
        if(true){
            a = 374;
        }
        if(true){
            a = 375;
        }
        if(true){
            a = 376;
        }
        if(true){
            a = 377;
        }
        if(true){
            a = 378;
        }
        if(true){
            a = 379;
        }
        if(true){
            a = 380;
        }
        if(true){
            a = 381;
        }
        if(true){
            a = 382;
        }
        if(true){
            a = 383;
        }
        if(true){
            a = 384;
        }
        if(true){
            a = 385;
        }
        if(true){
            a = 386;
        }
        if(true){
            a = 387;
        }
        if(true){
            a = 388;
        }
        if(true){
            a = 389;
        }
        if(true){
            a = 390;
        }
        if(true){
            a = 391;
        }
        if(true){
            a = 392;
        }
        if(true){
            a = 393;
        }
        if(true){
            a = 394;
        }
        if(true){
            a = 395;
        }
        if(true){
            a = 396;
        }
        if(true){
            a = 397;
        }
        if(true){
            a = 398;
        }
        if(true){
            a = 399;
        }
        if(true){
            a = 400;
        }
        if(true){
            a = 401;
        }
        if(true){
            a = 402;
        }
        if(true){
            a = 403;
        }
        if(true){
            a = 404;
        }
        if(true){
            a = 405;
        }
        if(true){
            a = 406;
        }
        if(true){
            a = 407;
        }
        if(true){
            a = 408;
        }
        if(true){
            a = 409;
        }
        if(true){
            a = 410;
        }
        if(true){
            a = 411;
        }
        if(true){
            a = 412;
        }
        if(true){
            a = 413;
        }
        if(true){
            a = 414;
        }
        if(true){
            a = 415;
        }
        if(true){
            a = 416;
        }
        if(true){
            a = 417;
        }
        if(true){
            a = 418;
        }
        if(true){
            a = 419;
        }
        if(true){
            a = 420;
        }
        if(true){
            a = 421;
        }
        if(true){
            a = 422;
        }
        if(true){
            a = 423;
        }
        if(true){
            a = 424;
        }
        if(true){
            a = 425;
        }
        if(true){
            a = 426;
        }
        if(true){
            a = 427;
        }
        if(true){
            a = 428;
        }
        if(true){
            a = 429;
        }
        if(true){
            a = 430;
        }
        if(true){
            a = 431;
        }
        if(true){
            a = 432;
        }
        if(true){
            a = 433;
        }
        if(true){
            a = 434;
        }
        if(true){
            a = 435;
        }
        if(true){
            a = 436;
        }
        if(true){
            a = 437;
        }
        if(true){
            a = 438;
        }
        if(true){
            a = 439;
        }
        if(true){
            a = 440;
        }
        if(true){
            a = 441;
        }
        if(true){
            a = 442;
        }
        if(true){
            a = 443;
        }
        if(true){
            a = 444;
        }
        if(true){
            a = 445;
        }
        if(true){
            a = 446;
        }
        if(true){
            a = 447;
        }
        if(true){
            a = 448;
        }
        if(true){
            a = 449;
        }
        if(true){
            a = 450;
        }
        if(true){
            a = 451;
        }
        if(true){
            a = 452;
        }
        if(true){
            a = 453;
        }
        if(true){
            a = 454;
        }
        if(true){
            a = 455;
        }
        if(true){
            a = 456;
        }
        if(true){
            a = 457;
        }
        if(true){
            a = 458;
        }
        if(true){
            a = 459;
        }
        if(true){
            a = 460;
        }
        if(true){
            a = 461;
        }
        if(true){
            a = 462;
        }
        if(true){
            a = 463;
        }
        if(true){
            a = 464;
        }
        if(true){
            a = 465;
        }
        if(true){
            a = 466;
        }
        if(true){
            a = 467;
        }
        if(true){
            a = 468;
        }
        if(true){
            a = 469;
        }
        if(true){
            a = 470;
        }
        if(true){
            a = 471;
        }
        if(true){
            a = 472;
        }
        if(true){
            a = 473;
        }
        if(true){
            a = 474;
        }
        if(true){
            a = 475;
        }
        if(true){
            a = 476;
        }
        if(true){
            a = 477;
        }
        if(true){
            a = 478;
        }
        if(true){
            a = 479;
        }
        if(true){
            a = 480;
        }
        if(true){
            a = 481;
        }
        if(true){
            a = 482;
        }
        if(true){
            a = 483;
        }
        if(true){
            a = 484;
        }
        if(true){
            a = 485;
        }
        if(true){
            a = 486;
        }
        if(true){
            a = 487;
        }
        if(true){
            a = 488;
        }
        if(true){
            a = 489;
        }
        if(true){
            a = 490;
        }
        if(true){
            a = 491;
        }
        if(true){
            a = 492;
        }
        if(true){
            a = 493;
        }
        if(true){
            a = 494;
        }
        if(true){
            a = 495;
        }
        if(true){
            a = 496;
        }
        if(true){
            a = 497;
        }
        if(true){
            a = 498;
        }
        if(true){
            a = 499;
        }
        if(true){
            a = 500;
        }
        if(true){
            a = 501;
        }
        if(true){
            a = 502;
        }
        if(true){
            a = 503;
        }
        if(true){
            a = 504;
        }
        if(true){
            a = 505;
        }
        if(true){
            a = 506;
        }
        if(true){
            a = 507;
        }
        if(true){
            a = 508;
        }
        if(true){
            a = 509;
        }
        if(true){
            a = 510;
        }
        if(true){
            a = 511;
        }
        if(true){
            a = 512;
        }
        if(true){
            a = 513;
        }
        return 1;
    }


    /*Temporary method only for tests*/
    public static Integer testDebug2(){
        Integer a = 0;
        if(true){
            a = 514;
        }
        if(true){
            a = 515;
        }
        if(true){
            a = 516;
        }
        if(true){
            a = 517;
        }
        if(true){
            a = 518;
        }
        if(true){
            a = 519;
        }
        if(true){
            a = 520;
        }
        if(true){
            a = 521;
        }
        if(true){
            a = 522;
        }
        if(true){
            a = 523;
        }
        if(true){
            a = 524;
        }
        if(true){
            a = 525;
        }
        if(true){
            a = 526;
        }
        if(true){
            a = 527;
        }
        if(true){
            a = 528;
        }
        if(true){
            a = 529;
        }
        if(true){
            a = 530;
        }
        if(true){
            a = 531;
        }
        if(true){
            a = 532;
        }
        if(true){
            a = 533;
        }
        if(true){
            a = 534;
        }
        if(true){
            a = 535;
        }
        if(true){
            a = 536;
        }
        if(true){
            a = 537;
        }
        if(true){
            a = 538;
        }
        if(true){
            a = 539;
        }
        if(true){
            a = 540;
        }
        if(true){
            a = 541;
        }
        if(true){
            a = 542;
        }
        if(true){
            a = 543;
        }
        if(true){
            a = 544;
        }
        if(true){
            a = 545;
        }
        if(true){
            a = 546;
        }
        if(true){
            a = 547;
        }
        if(true){
            a = 548;
        }
        if(true){
            a = 549;
        }
        if(true){
            a = 550;
        }
        if(true){
            a = 551;
        }
        if(true){
            a = 552;
        }
        if(true){
            a = 553;
        }
        if(true){
            a = 554;
        }
        if(true){
            a = 555;
        }
        if(true){
            a = 556;
        }
        if(true){
            a = 557;
        }
        if(true){
            a = 558;
        }
        if(true){
            a = 559;
        }
        if(true){
            a = 560;
        }
        if(true){
            a = 561;
        }
        if(true){
            a = 562;
        }
        if(true){
            a = 563;
        }
        if(true){
            a = 564;
        }
        if(true){
            a = 565;
        }
        if(true){
            a = 566;
        }
        if(true){
            a = 567;
        }
        if(true){
            a = 568;
        }
        if(true){
            a = 569;
        }
        if(true){
            a = 570;
        }
        if(true){
            a = 571;
        }
        if(true){
            a = 572;
        }
        if(true){
            a = 573;
        }
        if(true){
            a = 574;
        }
        if(true){
            a = 575;
        }
        if(true){
            a = 576;
        }
        if(true){
            a = 577;
        }
        if(true){
            a = 578;
        }
        if(true){
            a = 579;
        }
        if(true){
            a = 580;
        }
        if(true){
            a = 581;
        }
        if(true){
            a = 582;
        }
        if(true){
            a = 583;
        }
        if(true){
            a = 584;
        }
        if(true){
            a = 585;
        }
        if(true){
            a = 586;
        }
        if(true){
            a = 587;
        }
        if(true){
            a = 588;
        }
        if(true){
            a = 589;
        }
        if(true){
            a = 590;
        }
        if(true){
            a = 591;
        }
        if(true){
            a = 592;
        }
        if(true){
            a = 593;
        }
        if(true){
            a = 594;
        }
        if(true){
            a = 595;
        }
        if(true){
            a = 596;
        }
        if(true){
            a = 597;
        }
        if(true){
            a = 598;
        }
        if(true){
            a = 599;
        }
        if(true){
            a = 600;
        }
        if(true){
            a = 601;
        }
        if(true){
            a = 602;
        }
        if(true){
            a = 603;
        }
        if(true){
            a = 604;
        }
        if(true){
            a = 605;
        }
        if(true){
            a = 606;
        }
        if(true){
            a = 607;
        }
        if(true){
            a = 608;
        }
        if(true){
            a = 609;
        }
        if(true){
            a = 610;
        }
        if(true){
            a = 611;
        }
        if(true){
            a = 612;
        }
        if(true){
            a = 613;
        }
        if(true){
            a = 614;
        }
        if(true){
            a = 615;
        }
        if(true){
            a = 616;
        }
        if(true){
            a = 617;
        }
        if(true){
            a = 618;
        }
        if(true){
            a = 619;
        }
        if(true){
            a = 620;
        }
        if(true){
            a = 621;
        }
        if(true){
            a = 622;
        }
        if(true){
            a = 623;
        }
        if(true){
            a = 624;
        }
        if(true){
            a = 625;
        }
        if(true){
            a = 626;
        }
        if(true){
            a = 627;
        }
        if(true){
            a = 628;
        }
        if(true){
            a = 629;
        }
        if(true){
            a = 630;
        }
        if(true){
            a = 631;
        }
        if(true){
            a = 632;
        }
        if(true){
            a = 633;
        }
        if(true){
            a = 634;
        }
        if(true){
            a = 635;
        }
        if(true){
            a = 636;
        }
        if(true){
            a = 637;
        }
        if(true){
            a = 638;
        }
        if(true){
            a = 639;
        }
        if(true){
            a = 640;
        }
        if(true){
            a = 641;
        }
        if(true){
            a = 642;
        }
        if(true){
            a = 643;
        }
        if(true){
            a = 644;
        }
        if(true){
            a = 645;
        }
        if(true){
            a = 646;
        }
        if(true){
            a = 647;
        }
        if(true){
            a = 648;
        }
        if(true){
            a = 649;
        }
        if(true){
            a = 650;
        }
        if(true){
            a = 651;
        }
        if(true){
            a = 652;
        }
        if(true){
            a = 653;
        }
        if(true){
            a = 654;
        }
        if(true){
            a = 655;
        }
        if(true){
            a = 656;
        }
        if(true){
            a = 657;
        }
        if(true){
            a = 658;
        }
        if(true){
            a = 659;
        }
        if(true){
            a = 660;
        }
        if(true){
            a = 661;
        }
        if(true){
            a = 662;
        }
        if(true){
            a = 663;
        }
        if(true){
            a = 664;
        }
        if(true){
            a = 665;
        }
        if(true){
            a = 666;
        }
        if(true){
            a = 667;
        }
        if(true){
            a = 668;
        }
        if(true){
            a = 669;
        }
        if(true){
            a = 670;
        }
        if(true){
            a = 671;
        }
        if(true){
            a = 672;
        }
        if(true){
            a = 673;
        }
        if(true){
            a = 674;
        }
        if(true){
            a = 675;
        }
        if(true){
            a = 676;
        }
        if(true){
            a = 677;
        }
        if(true){
            a = 678;
        }
        if(true){
            a = 679;
        }
        if(true){
            a = 680;
        }
        if(true){
            a = 681;
        }
        if(true){
            a = 682;
        }
        if(true){
            a = 683;
        }
        if(true){
            a = 684;
        }
        if(true){
            a = 685;
        }
        if(true){
            a = 686;
        }
        if(true){
            a = 687;
        }
        if(true){
            a = 688;
        }
        if(true){
            a = 689;
        }
        if(true){
            a = 690;
        }
        if(true){
            a = 691;
        }
        if(true){
            a = 692;
        }
        if(true){
            a = 693;
        }
        if(true){
            a = 694;
        }
        if(true){
            a = 695;
        }
        if(true){
            a = 696;
        }
        if(true){
            a = 697;
        }
        if(true){
            a = 698;
        }
        if(true){
            a = 699;
        }
        if(true){
            a = 700;
        }
        if(true){
            a = 701;
        }
        if(true){
            a = 702;
        }
        if(true){
            a = 703;
        }
        if(true){
            a = 704;
        }
        if(true){
            a = 705;
        }
        if(true){
            a = 706;
        }
        if(true){
            a = 707;
        }
        if(true){
            a = 708;
        }
        if(true){
            a = 709;
        }
        if(true){
            a = 710;
        }
        if(true){
            a = 711;
        }
        if(true){
            a = 712;
        }
        if(true){
            a = 713;
        }
        if(true){
            a = 714;
        }
        if(true){
            a = 715;
        }
        if(true){
            a = 716;
        }
        if(true){
            a = 717;
        }
        if(true){
            a = 718;
        }
        if(true){
            a = 719;
        }
        if(true){
            a = 720;
        }
        if(true){
            a = 721;
        }
        if(true){
            a = 722;
        }
        if(true){
            a = 723;
        }
        if(true){
            a = 724;
        }
        if(true){
            a = 725;
        }
        if(true){
            a = 726;
        }
        if(true){
            a = 727;
        }
        if(true){
            a = 728;
        }
        if(true){
            a = 729;
        }
        if(true){
            a = 730;
        }
        if(true){
            a = 731;
        }
        if(true){
            a = 732;
        }
        if(true){
            a = 733;
        }
        if(true){
            a = 734;
        }
        if(true){
            a = 735;
        }
        if(true){
            a = 736;
        }
        if(true){
            a = 737;
        }
        if(true){
            a = 738;
        }
        if(true){
            a = 739;
        }
        if(true){
            a = 740;
        }
        if(true){
            a = 741;
        }
        if(true){
            a = 742;
        }
        if(true){
            a = 743;
        }
        if(true){
            a = 744;
        }
        if(true){
            a = 745;
        }
        if(true){
            a = 746;
        }
        if(true){
            a = 747;
        }
        if(true){
            a = 748;
        }
        if(true){
            a = 749;
        }
        if(true){
            a = 750;
        }
        if(true){
            a = 751;
        }
        if(true){
            a = 752;
        }
        if(true){
            a = 753;
        }
        if(true){
            a = 754;
        }
        if(true){
            a = 755;
        }
        if(true){
            a = 756;
        }
        if(true){
            a = 757;
        }
        if(true){
            a = 758;
        }
        if(true){
            a = 759;
        }
        if(true){
            a = 760;
        }
        if(true){
            a = 761;
        }
        if(true){
            a = 762;
        }
        if(true){
            a = 763;
        }
        if(true){
            a = 764;
        }
        if(true){
            a = 765;
        }
        if(true){
            a = 766;
        }
        if(true){
            a = 767;
        }
        if(true){
            a = 768;
        }
        if(true){
            a = 769;
        }
        if(true){
            a = 770;
        }
        if(true){
            a = 771;
        }
        if(true){
            a = 772;
        }
        if(true){
            a = 773;
        }
        if(true){
            a = 774;
        }
        if(true){
            a = 775;
        }
        if(true){
            a = 776;
        }
        if(true){
            a = 777;
        }
        if(true){
            a = 778;
        }
        if(true){
            a = 779;
        }
        if(true){
            a = 780;
        }
        if(true){
            a = 781;
        }
        if(true){
            a = 782;
        }
        if(true){
            a = 783;
        }
        if(true){
            a = 784;
        }
        if(true){
            a = 785;
        }
        if(true){
            a = 786;
        }
        if(true){
            a = 787;
        }
        if(true){
            a = 788;
        }
        if(true){
            a = 789;
        }
        if(true){
            a = 790;
        }
        if(true){
            a = 791;
        }
        if(true){
            a = 792;
        }
        if(true){
            a = 793;
        }
        if(true){
            a = 794;
        }
        if(true){
            a = 795;
        }
        if(true){
            a = 796;
        }
        if(true){
            a = 797;
        }
        if(true){
            a = 798;
        }
        if(true){
            a = 799;
        }
        if(true){
            a = 800;
        }
        if(true){
            a = 801;
        }
        if(true){
            a = 802;
        }
        if(true){
            a = 803;
        }
        if(true){
            a = 804;
        }
        if(true){
            a = 805;
        }
        if(true){
            a = 806;
        }
        if(true){
            a = 807;
        }
        if(true){
            a = 808;
        }
        if(true){
            a = 809;
        }
        if(true){
            a = 810;
        }
        if(true){
            a = 811;
        }
        if(true){
            a = 812;
        }
        if(true){
            a = 813;
        }
        if(true){
            a = 814;
        }
        if(true){
            a = 815;
        }
        if(true){
            a = 816;
        }
        if(true){
            a = 817;
        }
        if(true){
            a = 818;
        }
        if(true){
            a = 819;
        }
        if(true){
            a = 820;
        }
        if(true){
            a = 821;
        }
        if(true){
            a = 822;
        }
        if(true){
            a = 823;
        }
        if(true){
            a = 824;
        }
        if(true){
            a = 825;
        }
        if(true){
            a = 826;
        }
        if(true){
            a = 827;
        }
        if(true){
            a = 828;
        }
        if(true){
            a = 829;
        }
        if(true){
            a = 830;
        }
        if(true){
            a = 831;
        }
        if(true){
            a = 832;
        }
        if(true){
            a = 833;
        }
        if(true){
            a = 834;
        }
        if(true){
            a = 835;
        }
        if(true){
            a = 836;
        }
        if(true){
            a = 837;
        }
        if(true){
            a = 838;
        }
        if(true){
            a = 839;
        }
        if(true){
            a = 840;
        }
        if(true){
            a = 841;
        }
        if(true){
            a = 842;
        }
        if(true){
            a = 843;
        }
        if(true){
            a = 844;
        }
        if(true){
            a = 845;
        }
        if(true){
            a = 846;
        }
        if(true){
            a = 847;
        }
        if(true){
            a = 848;
        }
        if(true){
            a = 849;
        }
        if(true){
            a = 850;
        }
        if(true){
            a = 851;
        }
        if(true){
            a = 852;
        }
        if(true){
            a = 853;
        }
        if(true){
            a = 854;
        }
        if(true){
            a = 855;
        }
        if(true){
            a = 856;
        }
        if(true){
            a = 857;
        }
        if(true){
            a = 858;
        }
        if(true){
            a = 859;
        }
        if(true){
            a = 860;
        }
        if(true){
            a = 861;
        }
        if(true){
            a = 862;
        }
        if(true){
            a = 863;
        }
        if(true){
            a = 864;
        }
        if(true){
            a = 865;
        }
        if(true){
            a = 866;
        }
        if(true){
            a = 867;
        }
        if(true){
            a = 868;
        }
        if(true){
            a = 869;
        }
        if(true){
            a = 870;
        }
        if(true){
            a = 871;
        }
        if(true){
            a = 872;
        }
        if(true){
            a = 873;
        }
        if(true){
            a = 874;
        }
        if(true){
            a = 875;
        }
        if(true){
            a = 876;
        }
        if(true){
            a = 877;
        }
        if(true){
            a = 878;
        }
        if(true){
            a = 879;
        }
        if(true){
            a = 880;
        }
        if(true){
            a = 881;
        }
        if(true){
            a = 882;
        }
        if(true){
            a = 883;
        }
        if(true){
            a = 884;
        }
        if(true){
            a = 885;
        }
        if(true){
            a = 886;
        }
        if(true){
            a = 887;
        }
        if(true){
            a = 888;
        }
        if(true){
            a = 889;
        }
        if(true){
            a = 890;
        }
        if(true){
            a = 891;
        }
        if(true){
            a = 892;
        }
        if(true){
            a = 893;
        }
        if(true){
            a = 894;
        }
        if(true){
            a = 895;
        }
        if(true){
            a = 896;
        }
        if(true){
            a = 897;
        }
        if(true){
            a = 898;
        }
        if(true){
            a = 899;
        }
        if(true){
            a = 900;
        }
        if(true){
            a = 901;
        }
        if(true){
            a = 902;
        }
        if(true){
            a = 903;
        }
        if(true){
            a = 904;
        }
        if(true){
            a = 905;
        }
        if(true){
            a = 906;
        }
        if(true){
            a = 907;
        }
        if(true){
            a = 908;
        }
        if(true){
            a = 909;
        }
        if(true){
            a = 910;
        }
        if(true){
            a = 911;
        }
        if(true){
            a = 912;
        }
        if(true){
            a = 913;
        }
        if(true){
            a = 914;
        }
        if(true){
            a = 915;
        }
        if(true){
            a = 916;
        }
        if(true){
            a = 917;
        }
        if(true){
            a = 918;
        }
        if(true){
            a = 919;
        }
        if(true){
            a = 920;
        }
        if(true){
            a = 921;
        }
        if(true){
            a = 922;
        }
        if(true){
            a = 923;
        }
        if(true){
            a = 924;
        }
        if(true){
            a = 925;
        }
        if(true){
            a = 926;
        }
        if(true){
            a = 927;
        }
        if(true){
            a = 928;
        }
        if(true){
            a = 929;
        }
        if(true){
            a = 930;
        }
        if(true){
            a = 931;
        }
        if(true){
            a = 932;
        }
        if(true){
            a = 933;
        }
        if(true){
            a = 934;
        }
        if(true){
            a = 935;
        }
        if(true){
            a = 936;
        }
        if(true){
            a = 937;
        }
        if(true){
            a = 938;
        }
        if(true){
            a = 939;
        }
        if(true){
            a = 940;
        }
        if(true){
            a = 941;
        }
        if(true){
            a = 942;
        }
        if(true){
            a = 943;
        }
        if(true){
            a = 944;
        }
        if(true){
            a = 945;
        }
        if(true){
            a = 946;
        }
        if(true){
            a = 947;
        }
        if(true){
            a = 948;
        }
        if(true){
            a = 949;
        }
        if(true){
            a = 950;
        }
        if(true){
            a = 951;
        }
        if(true){
            a = 952;
        }
        if(true){
            a = 953;
        }
        if(true){
            a = 954;
        }
        if(true){
            a = 955;
        }
        if(true){
            a = 956;
        }
        if(true){
            a = 957;
        }
        if(true){
            a = 958;
        }
        if(true){
            a = 959;
        }
        if(true){
            a = 960;
        }
        if(true){
            a = 961;
        }
        if(true){
            a = 962;
        }
        if(true){
            a = 963;
        }
        if(true){
            a = 964;
        }
        if(true){
            a = 965;
        }
        if(true){
            a = 966;
        }
        if(true){
            a = 967;
        }
        if(true){
            a = 968;
        }
        if(true){
            a = 969;
        }
        if(true){
            a = 970;
        }
        if(true){
            a = 971;
        }
        if(true){
            a = 972;
        }
        if(true){
            a = 973;
        }
        if(true){
            a = 974;
        }
        if(true){
            a = 975;
        }
        if(true){
            a = 976;
        }
        if(true){
            a = 977;
        }
        if(true){
            a = 978;
        }
        if(true){
            a = 979;
        }
        if(true){
            a = 980;
        }
        if(true){
            a = 981;
        }
        if(true){
            a = 982;
        }
        if(true){
            a = 983;
        }
        if(true){
            a = 984;
        }
        if(true){
            a = 985;
        }
        if(true){
            a = 986;
        }
        if(true){
            a = 987;
        }
        if(true){
            a = 988;
        }
        if(true){
            a = 989;
        }
        if(true){
            a = 990;
        }
        if(true){
            a = 991;
        }
        if(true){
            a = 992;
        }
        if(true){
            a = 993;
        }
        if(true){
            a = 994;
        }
        if(true){
            a = 995;
        }
        if(true){
            a = 996;
        }
        if(true){
            a = 997;
        }
        if(true){
            a = 998;
        }
        if(true){
            a = 999;
        }
        if(true){
            a = 1000;
        }
        if(true){
            a = 1001;
        }
        if(true){
            a = 1002;
        }
        if(true){
            a = 1003;
        }
        if(true){
            a = 1004;
        }
        if(true){
            a = 1005;
        }
        if(true){
            a = 1006;
        }
        if(true){
            a = 1007;
        }
        if(true){
            a = 1008;
        }
        if(true){
            a = 1009;
        }
        if(true){
            a = 1010;
        }
        if(true){
            a = 1011;
        }
        if(true){
            a = 1012;
        }
        if(true){
            a = 1013;
        }
        if(true){
            a = 1014;
        }
        if(true){
            a = 1015;
        }
        if(true){
            a = 1016;
        }
        if(true){
            a = 1017;
        }
        if(true){
            a = 1018;
        }
        if(true){
            a = 1019;
        }
        if(true){
            a = 1020;
        }
        if(true){
            a = 1021;
        }
        if(true){
            a = 1022;
        }
        if(true){
            a = 1023;
        }
        if(true){
            a = 1024;
        }
        if(true){
            a = 1025;
        }
        if(true){
            a = 1026;
        }
        if(true){
            a = 1027;
        }
        if(true){
            a = 1028;
        }
        if(true){
            a = 1029;
        }
        if(true){
            a = 1030;
        }
        if(true){
            a = 1031;
        }
        if(true){
            a = 1032;
        }
        if(true){
            a = 1033;
        }
        if(true){
            a = 1034;
        }
        if(true){
            a = 1035;
        }
        if(true){
            a = 1036;
        }
        if(true){
            a = 1037;
        }
        if(true){
            a = 1038;
        }
        if(true){
            a = 1039;
        }
        if(true){
            a = 1040;
        }
        if(true){
            a = 1041;
        }
        if(true){
            a = 1042;
        }
        if(true){
            a = 1043;
        }
        if(true){
            a = 1044;
        }
        if(true){
            a = 1045;
        }
        return 1;
    }
}