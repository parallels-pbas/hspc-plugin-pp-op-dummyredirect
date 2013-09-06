## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
package HSPC::MT::Plugin::PP::OP_DummyRedirect;

use strict;
use HSPC::PluginToolkit::HTMLTemplate qw(parse_template);
use HSPC::PluginToolkit::General qw(string argparam uriparam);

use HSPC::PluginToolkit::PP qw(callback_url);

sub get_title {
	my $class = shift;
	
	return string('title_dummyredirect_plugin');
}

sub process_preauthorize {
	my $class = shift;
	return $class->_process_redirect(@_);
}

sub process_sale{
	my $class = shift;
	return $class->_process_redirect(@_);
}

sub _process_redirect {
	my $class = shift;
	my %h = (
			document_info => undef,
			ref_no        => undef,
			config        => undef,
			@_
	);

	my $config        = $h{config};
	my $url           = $config->{gateway_url};
	my $document_info = $h{document_info};
	my $ref_no        = $h{ref_no};
	
	## URL where redirect customers from Gate to.
	my $result_url = callback_url(action => 'return');

	## URL where sent notifications from Gate to.
	my $notify_url = callback_url(action => 'notify');

	my $redirect_hash = {
		url    => $url,
		method => "POST",
		attrs => {
			ref_no     => $ref_no,
			amount     => $document_info->{total},
			result_url => $result_url,
			notify_url => $notify_url,
		}
	};

	return {
		STATUS        => 'REDIRECT',
		REDIRECT_HASH => $redirect_hash,
	};
}

sub collect_transaction_refno{
	my $class = shift;
	my $ref_no = argparam('ref_no');
	return $ref_no;
}

sub process_callback{
	my $class = shift;
	my $url = $ENV{q}->url(-path_info => 1);
	my $action = uriparam('action');

	my $ret;

	if ($action eq "return") {
		my $status = argparam('return');
		my $code;
		my $desc;

		if ('Success' eq $status) {
			$code = "APPROVED";
			$desc = "Success";
		} elsif ('Failure' eq $status) {
			$code = "DECLINED";
			$desc = "Failure";
		} elsif ('Pending' eq $status) {
			$code = "PENDING";
			$desc = "Pending";
		} elsif ('Cancel'  eq $status) {
			$code = "DECLINED";
			$desc = "Cancel";
		}

		$ret =  {
			STATUS               => $code,
			TEXT                 => {
				customer_message => $desc,
			},
			ACTION => "restore_session",
		};
	} elsif ($action eq "notify") {
		$ret = $class->_process_notification();
	} elsif ($action eq "test-gate") {
		$ret = $class->_draw_test_gate();
	}

	return $ret;
}

sub _draw_test_gate {
	my $class  = shift;

	my $params = {
		amount     => argparam('amount')      || "",
		ref_no     => argparam('ref_no')      || "",
		notify_url => argparam('notify_url')  || "",
		result_url => argparam('result_url')  || "",
	};
	
	my $content = parse_template(
				path => __PACKAGE__,
				name => "gate_page.tmpl",
				data => $params,
		);

	return {
			CUSTOM_RESPONSE  => $content,
		};
}

sub _process_notification {
	my $class = shift;

	my $ret    = argparam('result');
	my $ref_no = argparam('ref_no');
	my $amount = argparam('amount');

	my $status;
	my $desc;
	my $details;

	if ('Success' eq $ret) {
		$status = "APPROVED";
		$desc = "Success";
	} elsif ('Failure' eq $ret) {
		$status = "DECLINED";
		$desc = "Failure";
	} elsif ('Pending' eq $ret) {
		$status = "PENDING";
		$desc = "Pending";
	} elsif ('Cancel'  eq $ret) {
		$status = "DECLINED";
		$desc = "Cancel";
	}

	$details->{desc} = $desc;

	return {
		TEXT                => {vendor_message => $desc},
		STATUS              => $status,
		TRANSACTION_DETAILS => $details,
		ACTION              => 'update',
		CUSTOM_RESPONSE     => 'Notification received!',
	};
}

sub get_currencies_supported{
	return [
				'ADP', # Andorran Peseta
				'AED', # UAE Dirham
				'AFA', # Afghani
				'ALL', # Lek
				'AMD', # Armenian Dram
				'ANG', # Antillian Guilder
				'AON', # New Kwanza
				'AOR', # Kwanza Reajustado
				'ARS', # Argentine Peso
				'ATS', # Schilling
				'AUD', # Australian Dollar
				'AWG', # Aruban Guilder
				'AZM', # Azerbaijanian Manat
				'BAM', # Convertible Marks
				'BBD', # Barbados Dollar
				'BDT', # Taka
				'BEF', # Belgian Franc
				'BGL', # Lev
				'BGN', # Bulgarian LEV
				'BHD', # Bahraini Dinar
				'BIF', # Burundi Franc
				'BMD', # Bermudian Dollar
				'BND', # Brunei Dollar
				'BRL', # Brazilian Real
				'BSD', # Bahamian Dollar
				'BTN', # Ngultrum
				'BWP', # Pula
				'BYR', # Belarussian Ruble
				'BZD', # Belize Dollar
				'CAD', # Canadian Dollar
				'CDF', # Franc Congolais
				'CHF', # Swiss Franc
				'CLF', # Unidades de fomento
				'CLP', # Chilean Peso
				'CNY', # Yuan Renminbi
				'COP', # Colombian Peso
				'CRC', # Costa Rican Colon
				'CUP', # Cuban Peso
				'CVE', # Cape Verde Escudo
				'CYP', # Cyprus Pound
				'CZK', # Czech Koruna
				'DEM', # Deutsche Mark
				'DJF', # Djibouti Franc
				'DKK', # Danish Krone
				'DOP', # Dominican Peso
				'DZD', # Algerian Dinar
				'ECS', # Sucre
				'ECV', # Unidad de Valor Constante (UVC)
				'EEK', # Kroon
				'EGP', # Egyptian Pound
				'ERN', # Nakfa
				'ESP', # Spanish Peseta
				'ETB', # Ethiopian Birr
				'EUR', # Euro
				'FIM', # Markka
				'FJD', # Fiji Dollar
				'FKP', # Pound
				'FRF', # French Franc
				'GBP', # Pound Sterling
				'GEL', # Lari
				'GHC', # Cedi
				'GIP', # Gibraltar Pound
				'GMD', # Dalasi
				'GNF', # Guinea Franc
				'GRD', # Drachma
				'GTQ', # Quetzal
				'GWP', # Guinea-Bissau Peso
				'GYD', # Guyana Dollar
				'HKD', # Hong Kong Dollar
				'HNL', # Lempira
				'HRK', # Kuna
				'HTG', # Gourde
				'HUF', # Forint
				'IDR', # Rupiah
				'IEP', # Irish Pound
				'ILS', # New Israeli Sheqel
				'INR', # Indian Rupee
				'IQD', # Iraqi Dinar
				'IRR', # Iranian Rial
				'ISK', # Iceland Krona
				'ITL', # Italian Lira
				'JMD', # Jamaican Dollar
				'JOD', # Jordanian Dinar
				'JPY', # Yen
				'KES', # Kenyan Shilling
				'KGS', # Som
				'KHR', # Riel
				'KMF', # Comoro Franc
				'KPW', # North Korean Won
				'KRW', # Won
				'KWD', # Kuwaiti Dinar
				'KYD', # Cayman Islands Dollar
				'KZT', # Tenge
				'LAK', # Kip
				'LBP', # Lebanese Pound
				'LKR', # Sri Lanka Rupee
				'LRD', # Liberian Dollar
				'LSL', # Loti
				'LTL', # Lithuanian Litas
				'LUF', # Luxembourg Franc
				'LVL', # Latvian Lats
				'LYD', # Libyan Dinar
				'MAD', # Moroccan Dirham
				'MDL', # Moldovan Leu
				'MGF', # Malagasy Franc
				'MKD', # Denar
				'MMK', # Kyat
				'MNT', # Tugrik
				'MOP', # Pataca
				'MRO', # Ouguiya
				'MTL', # Maltese Lira
				'MUR', # Mauritius Rupee
				'MVR', # Rufiyaa
				'MWK', # Kwacha
				'MXN', # Mexican Peso
				'MXV', # Mexican Unidad de Inversion (UDI)
				'MYR', # Malaysian Ringgit
				'MZM', # Metical
				'NAD', # Namibia Dollar
				'NGN', # Naira
				'NIO', # Cordoba Oro
				'NLG', # Netherlands Guilder
				'NOK', # Norwegian Krone
				'NPR', # Nepalese Rupee
				'NZD', # New Zealand Dollar
				'OMR', # Rial Omani
				'PAB', # Balboa
				'PEN', # Nuevo Sol
				'PGK', # Kina
				'PHP', # Philippine Peso
				'PKR', # Pakistan Rupee
				'PLN', # Zloty
				'PTE', # Portuguese Escudo
				'PYG', # Guarani
				'QAR', # Qatari Rial
				'ROL', # Leu
				'RUB', # Russian Ruble
				'RUR', # Russian Ruble
				'RWF', # Rwanda Franc
				'SAR', # Saudi Riyal
				'SBD', # Solomon Islands Dollar
				'SCR', # Seychelles Rupee
				'SDD', # Sudanese Dinar
				'SEK', # Swedish Krona
				'SGD', # Singapore Dollar
				'SHP', # St Helena Pound
				'SIT', # Tolar
				'SKK', # Slovak Koruna
				'SLL', # Leone
				'SOS', # Somali Shilling
				'SRG', # Surinam Guilder
				'STD', # Dobra
				'SVC', # El Salvador Colon
				'SYP', # Syrian Pound
				'SZL', # Lilangeni
				'THB', # Baht
				'TJR', # Tajik Ruble (old)
				'TJS', # Somoni
				'TMM', # Manat
				'TND', # Tunisian Dinar
				'TOP', # Pa'anga
				'TPE', # Timor Escudo
				'TRY', # Turkish Lira
				'TTD', # Trinidad and Tobago Dollar
				'TWD', # New Taiwan Dollar
				'TZS', # Tanzanian Shilling
				'UAH', # Hryvnia
				'UGX', # Uganda Shilling
				'USD', # US Dollar
				'USN', # (Next day)
				'USS', # (Same day)
				'UYU', # Peso Uruguayo
				'UZS', # Uzbekistan Sum
				'VEB', # Bolivar
				'VND', # Dong
				'VUV', # Vatu
				'WST', # Tala
				'XAF', # CFA Franc BEAC
				'XAG', # Silver
				'XAU', # Gold Bond Markets Units
				'XBA', # European Composite Unit (EURCO)
				'XBB', # European Monetary Unit (E.M.U.-6)
				'XBC', # European Unit of Account 9 (E.U.A.- 9)
				'XBD', # European Unit of Account 17 (E.U.A.- 17)
				'XCD', # East Caribbean Dollar
				'XDR', # SDR
				'XOF', # CFA Franc BCEAO
				'XPD', # Palladium
				'XPF', # CFP Franc
				'XPT', # Platinum
				'XTS', # Codes specifically reserved for testing purposes
				'YER', # Yemeni Rial
				'YUM', # New Dinar
				'ZAL', # (financial Rand)
				'ZAR', # Rand
				'ZMK', # Kwacha
				'ZRN', # New Zaire
				'ZWD', # Zimbabwe Dollar
		];
}


1;