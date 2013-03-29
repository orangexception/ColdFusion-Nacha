<cftry>

<cfscript>
oReturnService=	new	lib.orangexception.nacha.ReturnService();

qData=	queryNew( "bNachaCTXEnabled,CreditDebit,Amount,RoutingNumber,AccountNumber,IndividualID,Name" );

//queryAddRow( qData );
//querySetCell( qData , "bNachaCTXEnabled" , 0 );
//querySetCell( qData , "CreditDebit" , 'D' );
//querySetCell( qData , "Amount" , 46.00 );
//querySetCell( qData , "RoutingNumber" , '063000034' );
//querySetCell( qData , "AccountNumber" , '11111111123' );
//querySetCell( qData , "IndividualID" , 611984 );
//querySetCell( qData , "Name" , 'Test Biller & Co. "##+&/()' );
//
//queryAddRow( qData );
//querySetCell( qData , "bNachaCTXEnabled" , 0 );
//querySetCell( qData , "CreditDebit" , 'D' );
//querySetCell( qData , "Amount" , 400.00 );
//querySetCell( qData , "RoutingNumber" , '063000021' );
//querySetCell( qData , "AccountNumber" , '777777777' );
//querySetCell( qData , "IndividualID" , 611982 );
//querySetCell( qData , "Name" , 'Test Payer' );
//
//queryAddRow( qData );
//querySetCell( qData , "bNachaCTXEnabled" , 0 );
//querySetCell( qData , "CreditDebit" , 'CR' );
//querySetCell( qData , "Amount" , 200.00 );
//querySetCell( qData , "RoutingNumber" , '063000034' );
//querySetCell( qData , "AccountNumber" , '3434343434' );
//querySetCell( qData , "IndividualID" , 611982 );
//querySetCell( qData , "Name" , 'Test Payer 2' );

queryAddRow( qData );
querySetCell( qData , "bNachaCTXEnabled" , 0 );
querySetCell( qData , "CreditDebit" , 'D' );
querySetCell( qData , "Amount" , 63250.00 );
querySetCell( qData , "RoutingNumber" , '267084131' );
querySetCell( qData , "AccountNumber" , '47542659' );
querySetCell( qData , "IndividualID" , 'Batch 45069' );
querySetCell( qData , "Name" , 'KNQ Corp' );







sContent=	oReturnService.create(	qData ,
									"2621830443" ,
									"2621830443" ,
									"091000019" ,
									"PayCargo" ,
									"WELLS FARGO BANK" ,
									"BATCH ID 1205" );

writedump( sContent );

fileWrite( expandPath( "/ws/return.txt" ) , sContent );

writedump( oReturnService );abort;

</cfscript>

	<cfcatch>
		<cfdump	var=	"#cfcatch#" />
	</cfcatch>
</cftry>
<cfabort />