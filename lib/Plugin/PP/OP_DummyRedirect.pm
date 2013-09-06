## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
package HSPC::Plugin::PP::OP_DummyRedirect;

use strict;
use HSPC::PluginToolkit::HTMLTemplate qw(parse_template);
use HSPC::PluginToolkit::General qw(string argparam get_help_url);
use HSPC::PluginToolkit::PP qw(callback_url);

sub view_form {
	my $class = shift;
	my %h    = (
		config => undef,
		@_
	);
	my $config = $h{config};
	my $html;

	$html = parse_template(
				path => __PACKAGE__,
				name => 'op_dummyredirect_view.tmpl',
				data => { gateway_url => $config->{gateway_url} }
		);

	return $html;
}

sub edit_form{
	my $class = shift;
	my %h    = (
		config  => undef,
		@_
	);
	my $html;
	my $config = $h{config};
	
	$html = parse_template(
				path => __PACKAGE__,
				name => 'op_dummyredirect_edit.tmpl',
				data => {
					gateway_url => $config->{gateway_url} 
					 || callback_url(action => 'test-gate') 
					}
			);

	return $html;
}

sub collect_data{
	my $class = shift;
	my %h    = (
		config  => undef,
		@_
	);
	my $config = $h{config};

	$config->{gateway_url} = argparam('gateway_url');

	return $config;
}

sub get_help_page {
	my $class = shift;
	my %h    = (
		action  => undef,
		language  => undef,
		@_
	);

	my $action   = $h{action};
	my $language = $h{language};

	my  $html = parse_template(
				path => __PACKAGE__ . '::' . uc($language),
				name => "dummyredirect_$action.html",
				data => {
					about_url =>
					  get_help_url( action => 'about', language => $language, )
				},
			);

	return $html;
}

1;