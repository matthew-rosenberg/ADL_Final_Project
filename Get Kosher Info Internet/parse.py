import re
import requests
from bs4 import BeautifulSoup as BS

with open('symbols.html', encoding='utf-8') as f:
    soup = BS(f, 'html.parser')

sections = soup.find_all('li', attrs={
    'id': re.compile(r'huge_it_gallery_pupup_element_\d+')
})

email_re = r'\S+@[A-z0-9\-]+\.\w+'
phone_re = r'\(?\d\d\d[\) -]*\d\d\d[\- ]*\d\d\d\d'
for section in sections:
    name_text = section.find('h3', attrs={'class': 'title'})
    email_text = section.find(string=re.compile(email_re))
    phone_number_text = section.find(string=re.compile(phone_re))

    if not name_text:
        continue
    name = ' '.join(name_text.get_text().strip().split()).replace(',', '')

    if not email_text:
        email_text = ''

    if not phone_number_text:
        phone_number_text = ''

    email = re.search(email_re, email_text)
    phone_number = re.search(phone_re, phone_number_text)

    print(f'{name},{email.group(0) if email else ""},{phone_number.group(0) if phone_number else ""}')
