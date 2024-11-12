with ptitle as (select whti.bookkey, whti.ean13, whti.title, whti.primaryeditionworkkey, bm.textvalue, whtc.bisacstatus, bd.publishtowebind, bd.bisacstatuscode, dbo.rpt_get_date(whti.bookkey, 1, 8, 'B') 'PubDate'
  from whtitleinfo whti inner join whtitleclass whtc on whti.bookkey = whtc.bookkey left outer join bookmisc bm on whti.bookkey = bm.bookkey and bm.misckey = 171/*Open Access URL*/ inner join bookdetail bd on whti.bookkey = bd.bookkey
  where whti.primaryeditionworkkey = whti.bookkey and ((whti.media <> 'ebook format') or whti.format = 'All Ebooks (OA)') ) ,

subtitle as (select whti.bookkey, whti.ean13, whti.title, whti.primaryeditionworkkey, bm.textvalue , whtc.bisacstatus, bd.publishtowebind, bd.bisacstatuscode
  from whtitleinfo whti inner join whtitleclass whtc on whti.bookkey = whtc.bookkey left outer join bookmisc bm on whti.bookkey = bm.bookkey and bm.misckey = 171/*Open Access URL*/ inner join bookdetail bd on whti.bookkey = bd.bookkey
  where whti.primaryeditionworkkey <> whti.bookkey and (whti.media <> 'ebook format') and whtc.bisacstatus not in ('NYP Cancelled')),

currentOA as (select whti.bookkey, whti.ean13, whti.title, whti.primaryeditionworkkey, bm.textvalue, bd.bisacstatuscode, dbo.rpt_get_date(whti.bookkey, 1, 8, 'B') 'PubDate'
  from whtitleinfo whti left outer join bookmisc bm on whti.bookkey = bm.bookkey and bm.misckey = 171/*Open Access URL*/
  inner join bookdetail bd on whti.bookkey = bd.bookkey where whti.format like '%(OA)'),

ebook as (select whti.bookkey, whti.title, whti.ean13, at.bookkey 'pbookkey' , bd.publishtowebind, bd.bisacstatuscode
  from whtitleinfo whti inner join associatedtitles at on whti.bookkey = at.associatetitlebookkey inner join bookdetail bd on whti.bookkey = bd.bookkey
  where whti.media = 'ebook format' and whti.format = 'all ebooks' and at.associationtypecode = 4 and at.associationtypesubcode = 19/*linked in supply chain?*/)

select whti.bookkey, wha.authortype1, wha.authorlastname1, nullif(wha.authorfirstname1,'') 'authorfirstname1', wha.authortype2, wha.authorlastname2, nullif(wha.authorfirstname2,'') 'authorfirstname2', wha.authortype3, wha.authorlastname3, wha.authorfirstname3,
wha.authortype4, wha.authorlastname4, wha.authorfirstname4, wha.authortype5, wha.authorlastname5, wha.authorfirstname5, whti.fullauthordisplayname,
whti.titleprefixandtitle, nullif(whti.subtitle,'') 'subtitle', whtc.volume, whti.format, nullif(whti.childformat,'') 'childformat', YEAR(dbo.rpt_get_date(whti.bookkey, 1, 8, 'B')) 'pubyear', ptitle.ean13 'printISBN', ebook.ean13 'eISBN', whtc.groupentry3,
CASE WHEN dbo.rpt_get_misc_value_check(whti.bookkey, 243/*Full Text on Fulcrum*/, 'Y') = 'Y' and (dbo.rpt_get_misc_value(ebook.bookkey,286/*Fulcrum Status*/,'L') = 'Published' or dbo.rpt_get_misc_value(currentOA.bookkey,286/*Fulcrum Status*/,'L') = 'Published') THEN dbo.rpt_get_misc_value(whti.bookkey, 250/*Fulcrum URL*/, 'long')
     WHEN (ptitle.publishtowebind = 1 or subtitle.publishtowebind = 1 or ebook.publishtowebind = 1) and (ptitle.bisacstatuscode IN (1, 4, 5, 7) or subtitle.bisacstatuscode in (1, 4, 5, 7) or ebook.bisacstatuscode in (1, 4, 5, 7)) THEN CONCAT('https://www.press.umich.edu/',whti.primaryeditionworkkey)
	 ELSE 'https://www.press.umich.edu/forthcoming'
	 END
'resource',
whti.primaryeditionworkkey 'workkey',doi.textvalue 'doi', currentOA.textvalue 'OAURL',
ptitle.bisacstatus 'primaryBISAC',
subtitle.bisacstatus 'secondaryBISAC',
subtitle.ean13 'secondaryISBN',
case when whtc.groupentry2 = 'distributed' then whtc.groupentry3 end 'distClient',
dbo.rpt_get_misc_value_check(whti.bookkey, 243, 'Y') 'fullTextOnFulcrum',
dbo.rpt_get_misc_value(ebook.bookkey,286,'L') 'ebookStatus',
dbo.rpt_get_misc_value(currentOA.bookkey,286,'L') 'currentOAStatus'
from ptitle inner join whtitleinfo whti on ptitle.bookkey = whti.bookkey
left outer join ebook on ebook.pbookkey = ptitle.bookkey
inner join whauthor wha on whti.bookkey = wha.bookkey
inner join whtitleclass whtc on whti.bookkey = whtc.bookkey
inner join bookdetail bd on whti.bookkey = bd.bookkey
left outer join currentOA on ptitle.bookkey = currentOA.primaryeditionworkkey
left outer join bookmisc doi on ptitle.bookkey = doi.bookkey and doi.misckey = 199
left outer join subtitle on ptitle.bookkey = subtitle.primaryeditionworkkey
where (ptitle.bisacstatus in ('Temporarily out of Stock', 'On Demand', 'active', 'not yet published') or subtitle.bisacstatus in ('Temporarily out of Stock', 'On Demand', 'active', 'not yet published'))
and ptitle.ean13 is not null
and pubyear is not null
order by titleprefixandtitle
FOR XML RAW ('book'), ROOT ('root'), ELEMENTS;
