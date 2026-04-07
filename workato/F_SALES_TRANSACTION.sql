SELECT rps.document.sid as DOCUMENT_SID,
       rps.country.country_code,
       rps.document.store_code,
       itemcount.description2 as LOT_NUMBER,
       rps.document.workstation_no as REGISTER_NO,
       rps.document.cashier_login_name,
       to_char(rps.document.invc_post_date, 'yyyy-mm-dd hh24:mi:ss'),
       itemcount.qty_sold,
       itemcount.local_price,
       rps.currency.alphabetic_code,
       sum(itemcount.local_price * rps.exchange_rate.take_rate) as USD_Price
FROM rps.document,
     (select a.sid, a.subsidiary_sid, a.store_code, a.workstation_no, b.description2,
          case when a.subsidiary_sid = 573040816070296815 then sum(b.price)
              else sum(b.price - b.tax_amt)
          end as local_price, sum(qty) as qty_sold
          from rps.document a,
          (select item.doc_sid, item.description2,
              case when item.item_type = 2 then(-1 * qty * item.price)
                  else (qty * item.price)
              end as price,
              case when item.item_type = 2 then(-1 * qty)
                  else qty
              end as qty,                  
                  case when item.item_type = 2 then (-1 * qty * item.tax_amt)
                      else (qty * item.tax_amt)
                  end as tax_amt
                  from rps.document_item item,
                      rps.document doc,
                      rps.subsidiary sub
                  where doc.sid = item.doc_sid
                  and doc.subsidiary_sid = sub.sid
                  and doc.post_date > '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","startTime"]}')}'
                  and doc.post_date <= '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","endTime"]}')}') b,
                  rps.subsidiary c
                  where a.sid = b.doc_sid
                  and a.subsidiary_sid = c.sid
                  and a.post_date > '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","startTime"]}')}'
                  and a.post_date <= '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","endTime"]}')}'
                  group by a.sid, a.subsidiary_sid, a.store_code, a.workstation_no, b.description2) itemcount,
               rps.subsidiary ,
               rps.country ,
               rps.currency,
               rps.exchange_rate
WHERE  rps.document.sid = itemcount.sid
AND rps.document.workstation_no = itemcount.workstation_no
AND rps.document.subsidiary_sid = itemcount.subsidiary_sid
AND rps.document.store_code = itemcount.store_code
AND rps.document.subsidiary_sid = rps.subsidiary.sid
AND rps.subsidiary.country_sid = rps.country.sid
AND rps.subsidiary.base_currency_sid = rps.currency.sid
AND rps.exchange_rate.base_currency_sid = rps.currency.sid
and rps.document.post_date > '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","startTime"]}')}'
and rps.document.post_date <= '#{_dp('{"pill_type":"output","provider":"workato_recipe_function","line":"10eef848","path":["parameters","endTime"]}')}'
AND rps.exchange_rate.currency_sid = (select c1.sid from rps.currency c1 where c1.alphabetic_code = 'USD')
AND rps.exchange_rate.effective_date =
    (select max(r1.effective_date)
     from rps.exchange_rate r1
     where r1.base_currency_sid = rps.currency.sid
     and r1.currency_sid = exchange_rate.currency_sid
     and r1.effective_date <= rps.document.invc_post_date)
GROUP BY
    rps.document.sid,
    rps.country.country_code,
    rps.document.store_code,
    itemcount.description2 ,
    rps.document.workstation_no ,
    rps.document.cashier_login_name,
    rps.document.invc_post_date,
    qty_sold,
    local_price,
    rps.currency.alphabetic_code
