if exists (select * from dbo.sysobjects where id = object_id(N'dbo.UMP_DOI_MPS_UMPRE_Feed_View') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.UMP_DOI_MPS_UMPRE_Feed_View
GO
CREATE VIEW dbo.UMP_DOI_MPS_UMPRE_Feed_View
/*Used in Vcron job DOI Registration Export*/
AS
SELECT [bookkey] = c.bookkey,
[authortype1] = dbo.rpt_get_author_by_rank(c.bookkey,1,'T'),
[authorlastname1] = dbo.rpt_get_author_by_rank(c.bookkey,1,'L'),
[authorfirstname1] = dbo.rpt_get_author_by_rank(c.bookkey,1,'F'),
[authorprimaryind1] = dbo.rpt_get_author_by_rank(c.bookkey,1,'P'),
[authortype2] = dbo.rpt_get_author_by_rank(c.bookkey,2,'T'),
[authorlastname2] = dbo.rpt_get_author_by_rank(c.bookkey,2,'L'),
[authorfirstname2] = dbo.rpt_get_author_by_rank(c.bookkey,2,'F'),
[authorprimaryind2] = dbo.rpt_get_author_by_rank(c.bookkey,2,'P'),
[authortype3] = dbo.rpt_get_author_by_rank(c.bookkey,3,'T'),
[authorlastname3] = dbo.rpt_get_author_by_rank(c.bookkey,3,'L'),
[authorfirstname3] = dbo.rpt_get_author_by_rank(c.bookkey,3,'F'),
[authorprimaryind3] = dbo.rpt_get_author_by_rank(c.bookkey,3,'P'),
[authortype4] = dbo.rpt_get_author_by_rank(c.bookkey,4,'T'),
[authorlastname4] = dbo.rpt_get_author_by_rank(c.bookkey,4,'L'),
[authorfirstname4] = dbo.rpt_get_author_by_rank(c.bookkey,4,'F'),
[authorprimaryind4] = dbo.rpt_get_author_by_rank(c.bookkey,4,'P'),
[authortype5] = dbo.rpt_get_author_by_rank(c.bookkey,5,'T'),
[authorlastname5] = dbo.rpt_get_author_by_rank(c.bookkey,5,'L'),
[authorfirstname5] = dbo.rpt_get_author_by_rank(c.bookkey,5,'F'),
[authorprimaryind5] = dbo.rpt_get_author_by_rank(c.bookkey,5,'P'),
[fullauthordisplayname] = bd.fullauthordisplayname,
[titleprefixandtitle] = ISNULL(NULLIF(c.titleprefix + ' ',' '),'') + c.title,
[subtitle] = c.subtitle,
[volume] = bd.volumenumber,
[format1] = c.formatname,
[format2] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,2,'F'),
[format3] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,3,'F'),
[format4] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,4,'F'),
[format5] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,5,'F'),
[childformat] = dbo.rpt_get_child_format(c.bookkey),
[pubyear] = YEAR(dbo.rpt_get_date(c.bookkey, 1, 8, 'B')),
[ISBN1] = c.eanx,
[ISBN2] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,2,'I'),
[ISBN3] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,3,'I'),
[ISBN4] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,4,'I'),
[ISBN5] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,5,'I'),
[groupentry3] = dbo.rpt_get_group_level_3(c.bookkey,'F'),
[resource] = CASE WHEN dbo.rpt_get_misc_value_check(c.bookkey, 243/*Full Text on Fulcrum*/, 'Y') = 'Y' 
			and (dbo.rpt_get_misc_value(dbo.UMP_rpt_get_format_bookkey_by_format(c.bookkey,'E'),286/*Fulcrum Status*/,'L') = 'Published' 
			or dbo.rpt_get_misc_value(dbo.UMP_rpt_get_format_bookkey_by_format(c.bookkey,'OA'),286/*Fulcrum Status*/,'L') = 'Published') 
	THEN dbo.rpt_get_misc_value(c.bookkey, 250/*Fulcrum URL*/, 'long')
     WHEN (bd.publishtowebind = 1 or dbo.UMP_rpt_get_subformat_publishtoweb(c.bookkey) = 1) and (c.bisacstatuscode IN (1, 4, 5, 7) or dbo.UMP_rpt_get_subformat_bisacstatuscode(c.bookkey) = 1) THEN CONCAT('https://www.press.umich.edu/',c.workkey)
     ELSE 'https://www.press.umich.edu/forthcoming'
     END,
[workkey] = c.workkey,
[doi] = dbo.rpt_get_misc_value(c.bookkey,199,'long'), 
[OAURL] = dbo.rpt_get_misc_value(dbo.UMP_rpt_get_format_bookkey_by_format(c.bookkey,'OA'),171,'long'),
[BISAC1] = c.bisacstatusdesc,
[BISAC2] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,2,'BS'),
[BISAC3] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,3,'BS'),
[BISAC4] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,4,'BS'),
[BISAC5] = dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,5,'BS'),
[distClient] = case when dbo.rpt_get_group_level_2(c.bookkey,'F') = 'distributed' then dbo.rpt_get_group_level_3(c.bookkey,'F') end,
[fullTextOnFulcrum] = dbo.rpt_get_misc_value_check(c.bookkey, 243, 'Y'),
[ebookStatus] = dbo.rpt_get_misc_value(dbo.UMP_rpt_get_format_bookkey_by_format(c.bookkey,'E'),286,'L'),
[currentOAStatus] = dbo.rpt_get_misc_value(dbo.UMP_rpt_get_format_bookkey_by_format(c.bookkey,'OA'),286,'L'),
[eloquenceVerificationStatus] = dbo.rpt_get_verification_status(c.bookkey, 10)
FROM coretitleinfo c
JOIN bookdetail bd ON c.bookkey = bd.bookkey
WHERE c.bookkey = c.workkey
AND (c.bisacstatusdesc in ('Temporarily out of Stock', 'On Demand', 'active', 'not yet published') 
	or EXISTS(SELECT 1 FROM coretitleinfo WHERE bookkey = CAST(dbo.UMP_rpt_get_format_data_by_rank(c.bookkey,2,'B') AS int) AND bisacstatusdesc in ('Temporarily out of Stock', 'On Demand', 'active', 'not yet published')))
--	AND c.bookkey = 4845841
--AND c.bookkey = 14610450
AND c.eanx is not null
AND c.bestpubdate is not null
AND (c.mediatypecode <> 14 OR (c.mediatypecode = 14 AND NOT EXISTS (SELECT 1 FROM associatedtitles WHERE bookkey = c.bookkey and associationtypecode = 4)))
GO
GRANT ALL ON dbo.UMP_DOI_MPS_UMPRE_Feed_View to public
GO


